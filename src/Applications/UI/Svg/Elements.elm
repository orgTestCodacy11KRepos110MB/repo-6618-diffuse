module UI.Svg.Elements exposing (dropboxLogo, fissionLogo, ipfsLogo, loading, loadingWithSize, remoteStorageLogo)

import Svg exposing (..)
import Svg.Attributes exposing (..)



-- LOGOS


fissionLogo : Svg Never
fissionLogo =
    svg
        [ height "16"
        , viewBox "0 0 78 75"
        , width "15"
        ]
        [ Svg.path
            [ d "m63.5742168 100.955694c1.5771036-3.0862122 4.7865419-5.1990337 8.4892831-5.1990337 5.262292 0 9.5282225 4.2674257 9.5282225 9.5315617s-4.2659305 9.531562-9.5282225 9.531562c-3.7027412 0-6.9121795-2.112822-8.4892831-5.199034h-8.8347577c-8.1326331 0-14.7254348-6.595112-14.7254348-14.7305953 0-8.1354832 6.5928017-14.7305954 14.7254348-14.7305954h20.7582159l-3.5055762-5.1990337h-17.2526397c-8.1326331 0-14.7254348-6.5951122-14.7254348-14.7305954 0-8.1354831 6.5928017-14.7305953 14.7254348-14.7305953 4.7155931 0 8.662299 1.8213797 11.5238372 5.5612233.1866331.2439174.903725 1.2845631 2.5931092 3.7540648l7.7408874 11.4808465h26.6494811c3.348731 0 6.063414-2.7156344 6.063414-6.0655393 0-3.3499048-2.714683-6.0655392-6.063414-6.0655392h-8.8347582c-1.5771036 3.0862121-4.7865418 5.1990336-8.4892831 5.1990336-5.262292 0-9.5282225-4.2674255-9.5282225-9.5315617s4.2659305-9.5315617 9.5282225-9.5315617c3.7027413 0 6.9121795 2.1128215 8.4892831 5.1990337h8.8347582c8.132633 0 14.725434 6.5951122 14.725434 14.7305953 0 8.1354832-6.592801 14.7305954-14.725434 14.7305954h-20.8071225l3.5054152 5.1990337h17.3017073c8.132633 0 14.725434 6.5951122 14.725434 14.7305954 0 8.1354833-6.592801 14.7305953-14.725434 14.7305953-4.5017474 0-8.6780769-2.039045-11.619773-5.691322l-2.14253-3.026397-8.1441689-12.0784156h-26.600843c-3.3487313 0-6.0634143 2.7156345-6.0634143 6.0655393s2.714683 6.0655393 6.0634143 6.0655393zm33.0344752-4.9804486 1.9194061 2.7245712c1.1480037 1.4198784 2.8602789 2.2558774 4.7186759 2.2558774 3.348731 0 6.063414-2.7156345 6.063414-6.0655393s-2.714683-6.0655393-6.063414-6.0655393h-11.4593486zm-34.9169674-36.2909507c-1.3624245-1.9914187-2.2731584-3.3130783-2.3068102-3.3570589-1.1682567-1.5268352-2.5464113-2.1628448-4.6454553-2.1628448-3.3487313 0-6.0634143 2.7156344-6.0634143 6.0655392 0 3.3499049 2.714683 6.0655393 6.0634143 6.0655393h11.4100126z"
            , fill "currentColor"
            , transform "translate(-40, -40)"
            ]
            []
        ]


ipfsLogo : Svg Never
ipfsLogo =
    svg
        [ height "16"
        , viewBox "0 0 511.99999 511.99998"
        , width "16"
        ]
        [ -- Group 1
          ----------
          g
            [ transform "translate(-50.017 -515.51)" ]
            [ Svg.path
                [ d "m283.13 546.35-160.74 92.806c0.32126 2.8543 0.32125 5.7352 0 8.5894l160.75 92.806c13.554-10.001 32.043-10.001 45.597 0l160.75-92.807c-0.32126-2.8543-0.32293-5.7338-0.001-8.588l-160.74-92.806c-13.554 10.001-32.044 10.001-45.599 0zm221.79 127.03-160.92 93.84c1.884 16.739-7.3611 32.751-22.799 39.489l0.18062 184.58c2.6325 1.1489 5.1267 2.5886 7.438 4.294l160.75-92.805c-1.884-16.739 7.3611-32.752 22.799-39.49v-185.61c-2.6325-1.1489-5.1281-2.5886-7.4394-4.294zm-397.81 1.0315c-2.3112 1.7054-4.8054 3.1465-7.438 4.2954v185.61c15.438 6.7378 24.683 22.75 22.799 39.489l160.74 92.806c2.3112-1.7054 4.8069-3.1465 7.4394-4.2954v-185.61c-15.438-6.7378-24.683-22.75-22.799-39.489l-160.74-92.81z"
                , fill "currentColor"
                ]
                []
            ]

        -- Group 2
        ----------
        , g
            [ fill "currentColor"
            , transform "translate(0 -196.66)"
            ]
            [ Svg.path
                [ d "m256 708.66 221.7-128v-256l-221.7 128v256z"
                , fillOpacity "1"
                ]
                []
            , Svg.path
                [ d "m256 708.66v-256l-221.7-128v256l221.7 128z"
                , fillOpacity ".75"
                ]
                []
            , Svg.path
                [ d "m34.298 324.66 221.7 128 221.7-128-221.7-128-221.7 128z"
                , fillOpacity ".5"
                ]
                []
            ]
        ]


dropboxLogo : Svg Never
dropboxLogo =
    svg
        [ height "16"
        , viewBox "0 0 43 40"
        , width "16"
        ]
        [ Svg.path
            [ d "m12.5 0l-12.5 8.1 8.7 7 12.5-7.8-8.7-7.3zm-12.5 21.9l12.5 8.2 8.7-7.3-12.5-7.7-8.7 6.8zm21.2 0.9l8.8 7.3 12.4-8.1-8.6-6.9-12.6 7.7zm21.2-14.7l-12.4-8.1-8.8 7.3 12.6 7.8 8.6-7zm-21.1 16.3l-8.8 7.3-3.7-2.5v2.8l12.5 7.5 12.5-7.5v-2.8l-3.8 2.5-8.7-7.3z"

            --
            , fill "currentColor"
            ]
            []
        ]


remoteStorageLogo : Svg Never
remoteStorageLogo =
    svg
        [ clipRule "evenodd"
        , fillRule "evenodd"
        , height "16"
        , imageRendering "optimizeQuality"
        , shapeRendering "geometricPrecision"
        , textRendering "geometricPrecision"
        , viewBox "0 0 739 853"
        , width "16"
        ]
        [ polygon
            [ points "370,754 0,542 0,640 185,747 370,853 554,747 739,640 739,525 739,525 739,476 739,427 739,378 653,427 370,589 86,427 86,427 86,361 185,418 370,524 554,418 653,361 739,311 739,213 739,213 554,107 370,0 185,107 58,180 144,230 228,181 370,100 511,181 652,263 370,425 87,263 87,263 0,213 0,213 0,311 0,378 0,427 0,476 86,525 185,582 370,689 554,582 653,525 653,590 653,592"

            --
            , fill "currentColor"
            ]
            []
        ]



-- LOADING ANIMATION


loading : Svg Never
loading =
    loadingWithSize 29


loadingWithSize : Int -> Svg Never
loadingWithSize size =
    svg
        [ class "loading-animation"
        , height (String.fromInt size)
        , viewBox "0 0 30 30"
        , width (String.fromInt size)
        ]
        [ circle
            [ class "loading-animation__circle"
            , cx "15"
            , cy "15"
            , fill "none"
            , r "14"
            , strokeLinecap "round"
            , strokeWidth "2"
            ]
            []
        ]
