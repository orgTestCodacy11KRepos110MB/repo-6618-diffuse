module Http.Ext exposing (errorToString)

import Http exposing (Error(..))
import Json.Decode as Json



-- 🛠


errorToString : Http.Error -> String
errorToString err =
    -- Thanks to: https://github.com/hercules-ci/elm-hercules-extras/blob/1.0.0/src/Http/Extras.elm
    case err of
        Timeout ->
            "Timeout exceeded"

        NetworkError ->
            "Network error"

        BadStatus code ->
            "Something went wrong, got status code: " ++ String.fromInt code

        BadBody text ->
            "Unexpected response: " ++ text

        BadUrl url ->
            "Malformed url: " ++ url



-- ㊙️


parseError : String -> Maybe String
parseError =
    Json.decodeString (Json.field "error" Json.string) >> Result.toMaybe
