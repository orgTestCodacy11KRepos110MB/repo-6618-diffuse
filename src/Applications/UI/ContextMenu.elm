module UI.ContextMenu exposing (view)

import Chunky exposing (..)
import Classes as C
import Color exposing (Color)
import Conditional exposing (..)
import ContextMenu exposing (..)
import Coordinates exposing (Coordinates)
import Css
import Html.Styled exposing (Html, fromUnstyled, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Json.Decode
import Svg exposing (Svg)
import Tachyons.Classes as T
import UI.Core
import UI.Kit



-- 🗺


view : Maybe (ContextMenu UI.Core.Msg) -> Html UI.Core.Msg
view m =
    case m of
        Just (ContextMenu items coordinates) ->
            brick
                [ css (menuStyles coordinates)

                --
                , Html.Styled.Events.custom
                    "click"
                    (Json.Decode.succeed
                        { message = UI.Core.HideContextMenu
                        , stopPropagation = True
                        , preventDefault = True
                        }
                    )
                ]
                [ T.absolute
                , T.br2
                , T.bg_white
                , T.f7
                , T.overflow_hidden
                , T.z_9999
                ]
                (let
                    lastIndex =
                        List.length items - 1
                 in
                 List.indexedMap
                    (itemView lastIndex)
                    items
                )

        Nothing ->
            nothing


itemView : Int -> Int -> ( Color -> Int -> Svg msg, String, msg ) -> Html msg
itemView lastIndex index ( icon, label, msg ) =
    let
        isLast =
            index == lastIndex
    in
    brick
        [ onClick msg ]
        [ T.b__near_white
        , T.pa3
        , T.pointer

        --
        , ifThenElse isLast "" T.bb
        ]
        [ inline [ T.dib, C.lh_0, T.v_mid ] [ fromUnstyled (icon UI.Kit.colors.text 14) ]
        , inline [ T.dib, T.ml2, T.v_mid ] [ text label ]
        ]



-- 🖼


menuStyles : Coordinates -> List Css.Style
menuStyles { x, y } =
    [ Css.fontSize (Css.px 12.5)
    , Css.left (Css.px x)
    , Css.minWidth (Css.px 170)
    , Css.transform (Css.translate2 (Css.pct -50) (Css.pct -50))
    , Css.top (Css.px y)

    --
    , Css.property
        "box-shadow"
        "0 1px 3px 0 rgba(0, 0, 0, 0.225), 0 3px 15px 0 rgba(0, 0, 0, 0.1)"
    ]
