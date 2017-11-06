//
// Authentication
// [≡] 〆(・⺫・‶)
//
// Different integrations for authentication:
// 1. Local (indexedDB)
// 2. Blockstack
// 3. Remote Storage

const AUTH_SYSTEM = {};



//
// 🖍 Utensils

function construct(workerName) {
  return new Promise((resolve, reject) => {
    let worker;

    worker = new Worker(`/workers/authentication/${workerName}.js`);
    worker.onmessage = event => {
      worker.onmessage = null;

      switch (event.data.action) {
        case "CONSTRUCT_SUCCESS": return resolve(worker);
        case "CONSTRUCT_FAILURE": return reject();
      }
    };
  });
}


function doWork(worker, requisites) {
  const timeoutId = setTimeout(_ => {
    requisites.reject("Failed to reach web worker");
  }, 60000);

  // Wait for response from worker,
  // have timeout as fallback.
  const patchedHandler = event => {
    worker.removeEventListener("message", patchedHandler);
    clearTimeout(timeoutId);
    requisites.handler(event);
  };

  worker.addEventListener("message", patchedHandler);
  worker.postMessage({ action: requisites.action, data: requisites.data });
}



//
// > Method

const METHOD_KEY =
  "authenticationMethod";


AUTH_SYSTEM.METHOD =
  { get:    _ => localStorage.getItem(METHOD_KEY)
  , set:    v => localStorage.setItem(METHOD_KEY, v)
  , unset:  _ => localStorage.removeItem(METHOD_KEY)
  };



//
// 1. Local

(() => {

  let ID = "authenticationMethod.LOCAL";
  let worker;


  AUTH_SYSTEM.LOCAL = {

    construct() {
      return construct("local").then(w => worker = w);
    },


    deconstruct() {
      worker.terminate();
      worker = null;

      return Promise.resolve();
    },


    // In & Out


    isSignedIn:
      () => Promise.resolve(!!localStorage.getItem(ID)),


    isSigningIn:
      () => Promise.resolve(false),


    handleSignInProcess:
      () => Promise.resolve("KeepUrl"),


    signIn() {
      localStorage.setItem(ID, "t");
      return Promise.resolve("None");
    },


    signOut() {
      localStorage.removeItem(ID);
      return Promise.resolve();
    },


    // Data


    getData: _ => new Promise((resolve, reject) => {
      const handler = event => {
        switch (event.data.action) {
          case "GET_SUCCESS":   return event.data.data
                                    ? resolve( event.data.data )
                                    : resolve( null );

          case "GET_FAILURE":   return reject("Failed to get data");
          default:              return reject("Unavailable");
        }
      };

      doWork(worker, {
        action: "GET",
        data: null,
        resolve: resolve,
        reject: reject,
        handler: handler
      });
    }),


    storeData: json => new Promise((resolve, reject) => {
      const handler = event => {
        switch (event.data.action) {
          case "SET_SUCCESS":   return resolve();
          case "SET_FAILURE":   return reject("Failed to store data");
          default:              return reject("Unavailable");
        }
      };

      doWork(worker, {
        action: "SET",
        data: json,
        resolve: resolve,
        reject: reject,
        handler: handler
      });
    })

  }

})();



//
// 2. Blockstack

(() => {

  let KEY = "isotach.json";
  let worker;


  AUTH_SYSTEM.BLOCKSTACK = {

    construct() {
      return construct("blockstack").then(w => worker = w);
    },


    deconstruct() {
      worker.terminate();
      worker = null;

      return Promise.resolve();
    },


    // In & Out


    isSignedIn:
      () => Promise.resolve(blockstack.isUserSignedIn()),


    isSigningIn:
      () => Promise.resolve(blockstack.isSignInPending()),


    handleSignInProcess:
      () => blockstack.handlePendingSignIn().then(_ => "ModifyUrl"),


    signIn() {
      blockstack.redirectToSignIn();
      return Promise.resolve("Redirect");
    },


    signOut() {
      blockstack.signUserOut();
      return Promise.resolve();
    },


    // Data


    getData: _ => blockstack.getFile(KEY),


    storeData: json => blockstack.putFile(KEY, json)

  }

})();



//
// 3. Remote Storage

(() => {

  let rs;
  let worker;


  function setInstance() {
    if (rs) return;
    rs = new RemoteStorage({ cache: false });
    rs.access.claim("isotach", "rw");
  }

  function destroyInstance() {
    if (!rs) return;
    rs.disconnect();
    rs = null;
  }


  AUTH_SYSTEM.REMOTE_STORAGE = {

    construct() {
      return construct("remoteStorage").then(w => worker = w);
    },


    deconstruct() {
      worker.terminate();
      worker = null;

      return Promise.resolve();
    },


    // In & Out


    isSignedIn: _ => new Promise((resolve, reject) => {
      setInstance();

      const timeoutId = setTimeout(() => {
        resolve(false);
        rs.off("connected");
      }, 10000);

      rs.on("connected", _ => {
        clearTimeout(timeoutId);
        resolve(true);
        rs.off("connected");
      });
    }),


    isSigningIn:
      () => Promise.resolve(false),


    handleSignInProcess:
      () => Promise.resolve("KeepUrl"),


    signIn: _ => new Promise((resolve, reject) => {
      const userAddress = prompt(
        "What's your user address?"
      );

      if (!userAddress || userAddress.length === 0) {
        return resolve("GoBack");
      }

      setInstance();

      rs.on("connected", _ => resolve("Redirect"));
      rs.on("error", err => reject(err.message));
      rs.connect(userAddress);
    }),


    signOut() {
      setInstance();
      destroyInstance();

      return Promise.resolve();
    },


    // Data


    getData: _ => new Promise((resolve, reject) => {
      const handler = event => {
        switch (event.data.action) {
          case "GET_SUCCESS":   return event.data.data
                                    ? resolve( event.data.data )
                                    : resolve( null );

          case "GET_FAILURE":   return reject(`Failed to get data, ${event.data.data}.`);
          default:              return reject("Unavailable");
        }
      };

      doWork(worker, {
        action: "GET",
        data: { token: rs.remote.token, userAddress: rs.remote.userAddress },
        resolve: resolve,
        reject: reject,
        handler: handler
      });
    }),


    storeData: json => new Promise((resolve, reject) => {
      const handler = event => {
        switch (event.data.action) {
          case "SET_SUCCESS":   return resolve();
          case "SET_FAILURE":   return reject(`Failed to store data, ${event.data.data}.`);
          default:              return reject("Unavailable");
        }
      };

      doWork(worker, {
        action: "SET",
        data: { json: json, token: rs.remote.token, userAddress: rs.remote.userAddress },
        resolve: resolve,
        reject: reject,
        handler: handler
      });
    })

  }

})();
