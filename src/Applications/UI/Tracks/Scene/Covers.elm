module UI.Tracks.Scene.Covers exposing (containerId, scrollToNowPlaying, scrollToTop, view)

import Browser.Dom as Dom
import Chunky exposing (..)
import Color exposing (Color)
import Color.Ext as Color
import Color.Manipulate as Color
import Conditional exposing (ifThenElse)
import Coordinates
import Css.Classes as C
import Dict exposing (Dict)
import Html exposing (Html, text)
import Html.Attributes as A exposing (class, id, style, tabindex)
import Html.Events as E
import Html.Events.Extra.Mouse as Mouse
import Html.Lazy
import InfiniteList
import Json.Decode as Decode
import List.Ext as List
import List.Extra as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Maybe.Extra as Maybe
import Queue
import Task
import Tracks exposing (..)
import UI.DnD as DnD
import UI.Kit
import UI.Queue.Types as Queue
import UI.Tracks.Scene as Scene
import UI.Tracks.Scene.List
import UI.Tracks.Types exposing (Msg(..))
import UI.Types as UI exposing (Msg(..))



-- 🗺


type alias Dependencies =
    { bgColor : Maybe Color
    , cachedCovers : Maybe (Dict String String)
    , covers : List Cover
    , darkMode : Bool
    , favouritesOnly : Bool
    , infiniteList : InfiniteList.Model
    , isVisible : Bool
    , nowPlaying : Maybe Queue.Item
    , selectedCover : Maybe Cover
    , selectedTrackIndexes : List Int
    , sortBy : SortBy
    , sortDirection : SortDirection
    , viewportHeight : Float
    , viewportWidth : Float
    }


type alias ItemDependencies =
    { cachedCovers : Maybe (Dict String String)
    , nowPlaying : Maybe Queue.Item
    , sortBy : SortBy
    }


view : Dependencies -> Html Msg
view deps =
    Html.Lazy.lazy view_ deps


view_ : Dependencies -> Html Msg
view_ deps =
    chunk
        [ C.flex
        , C.flex_basis_0
        , C.flex_col
        , C.flex_grow
        , C.relative
        ]
        [ collectionView deps
        , case deps.selectedCover of
            Just cover ->
                singleCoverView cover deps

            Nothing ->
                nothing
        ]



-- 🏞  ░░  COLLECTION


collectionView : Dependencies -> Html Msg
collectionView deps =
    let
        amountOfCovers =
            List.length deps.covers
    in
    brick
        ((::)
            (tabindex (ifThenElse deps.isVisible 0 -1))
            viewAttributes
        )
        [ C.flex_basis_0
        , C.flex_grow
        , C.outline_none
        , C.overflow_x_hidden
        , C.overflow_y_auto
        , C.relative
        , C.scrolling_touch
        , C.text_almost_sm
        ]
        [ chunk
            [ C.flex
            , C.items_center
            , C.mt_5
            , C.mx_5
            ]
            [ sortGroupButtons deps.sortBy

            --
            , chunk
                [ C.flex
                , C.flex_auto
                , C.items_center
                , C.justify_end
                , C.text_base05
                , C.text_right
                , C.text_xs
                ]
                [ text (String.fromInt amountOfCovers)
                , case deps.sortBy of
                    Album ->
                        text " albums"

                    Artist ->
                        text " artists"

                    _ ->
                        nothing
                , text " "
                , slab
                    Html.span
                    [ deps.sortBy
                        |> SortBy
                        |> TracksMsg
                        |> E.onClick

                    --
                    , case deps.sortDirection of
                        Asc ->
                            A.title "Sorted alphabetically ascending"

                        Desc ->
                            A.title "Sorted alphabetically descending"
                    ]
                    [ C.cursor_pointer
                    , C.ml_1
                    , C.opacity_60
                    ]
                    [ case deps.sortDirection of
                        Asc ->
                            Icons.arrow_downward 16 Inherit

                        Desc ->
                            Icons.arrow_upward 16 Inherit
                    ]
                ]
            ]

        --
        , infiniteListView deps
        ]


containerId : String
containerId =
    "diffuse__track-covers"


scrollToNowPlaying : List IdentifiedTrack -> IdentifiedTrack -> Cmd Msg
scrollToNowPlaying harvest ( identifiers, _ ) =
    Cmd.none


scrollToTop : Cmd Msg
scrollToTop =
    Task.attempt (always UI.Bypass) (Dom.setViewportOf containerId 0 0)


viewAttributes : List (Html.Attribute Msg)
viewAttributes =
    [ InfiniteList.onScroll (InfiniteListMsg >> TracksMsg)
    , id containerId
    ]



-- 🏞  ░░  SINGLE COVER


singleCoverView : Cover -> Dependencies -> Html Msg
singleCoverView cover deps =
    let
        derivedColors =
            UI.Tracks.Scene.List.deriveColors
                { bgColor = deps.bgColor
                , darkMode = deps.darkMode
                }
    in
    brick
        [ tabindex (ifThenElse deps.isVisible 0 -1) ]
        [ C.absolute
        , C.bg_white
        , C.flex_basis_0
        , C.flex_grow
        , C.inset_0
        , C.leading_tight
        , C.outline_none
        , C.overflow_x_hidden
        , C.overflow_y_auto
        , C.text_almost_sm

        -- Dark mode
        ------------
        , C.dark__bg_darkest_hour
        ]
        [ chunk
            [ C.flex
            , C.font_semibold
            , C.h_8
            , C.items_center
            , C.leading_none
            , C.minus_ml_2
            , C.mt_5
            , C.px_5
            ]
            [ headerButton
                [ E.onClick (TracksMsg DeselectCover) ]
                { active = False
                , label = Icons.arrow_back 16 Inherit
                }

            --
            , headerButton
                [ Mouse.onClick (showCoverMenu cover) ]
                { active = True
                , label = Icons.more_horiz 16 Inherit
                }
            ]

        --
        , chunk
            [ C.mb_6
            , C.flex
            , C.minus_top_px
            , C.ml_5
            , C.mt_4
            , C.relative
            ]
            [ itemView
                { clickable = False }
                (compileItemDependencies deps)
                cover

            --
            , chunk
                [ C.flex_auto
                , C.flex_basis_0
                , C.ml_5
                , C.mr_5
                , C.overflow_hidden
                , C.select_none
                ]
                (List.indexedMap
                    (UI.Tracks.Scene.List.defaultItemView
                        { derivedColors = derivedColors
                        , favouritesOnly = deps.favouritesOnly
                        , nowPlaying = deps.nowPlaying
                        , roundedCorners = True
                        , selectedTrackIndexes = deps.selectedTrackIndexes
                        , showAlbum = not cover.sameAlbum
                        , showArtist = deps.sortBy /= Artist && not cover.sameArtist
                        , showGroup = False
                        }
                        0
                    )
                    cover.tracks
                )
            ]
        ]



-- 🧕


headerButton attributes { active, label } =
    brick
        attributes
        [ C.cursor_pointer
        , C.inline_flex
        , C.h_8
        , C.items_center
        , C.overflow_hidden
        , C.px_2
        , C.rounded

        --
        , ifThenElse active C.bg_gray_300 C.bg_transparent
        , ifThenElse active C.dark__bg_base01 C.dark__bg_transparent
        ]
        [ chunk
            [ C.mt_px, C.pt_px ]
            [ label ]
        ]


showCoverMenu : Cover -> Mouse.Event -> Msg
showCoverMenu cover =
    .clientPos
        >> Coordinates.fromTuple
        >> (TracksMsg << ShowCoverMenu cover)



-- SORTING


sortGroupButtons : SortBy -> Html Msg
sortGroupButtons sortBy =
    chunk
        [ C.flex
        , C.h_8
        , C.items_center
        , C.leading_none
        , C.mr_3
        , C.text_xs
        , C.tracking_tad_further
        ]
        [ sortGroupButton
            { current = sortBy, btn = Artist }
            (chunk
                [ C.inline_flex, C.items_center ]
                [ inline [ C.mr_px ] [ Icons.people_alt 16 Inherit ]
                , inline [ C.ml_1, C.mt_px, C.pl_px, C.pt_px ] [ text "Artists" ]
                ]
            )

        --
        , sortGroupButton
            { current = sortBy, btn = Album }
            (chunk
                [ C.inline_flex, C.items_center ]
                [ inline [ C.mr_px ] [ Icons.album 16 Inherit ]
                , inline [ C.ml_1, C.mt_px, C.pt_px ] [ text "Albums" ]
                ]
            )
        ]


sortGroupButton : { current : SortBy, btn : SortBy } -> Html Msg -> Html Msg
sortGroupButton { current, btn } label =
    headerButton
        [ btn
            |> SortBy
            |> TracksMsg
            |> E.onClick

        --
        , class C.mr_1
        ]
        { active = current == btn
        , label = label
        }



-- INFINITE LIST


infiniteListView : Dependencies -> Html Msg
infiniteListView deps =
    let
        itemDeps =
            compileItemDependencies deps

        viewportWidth =
            round deps.viewportWidth

        ( _, a, b ) =
            List.foldl
                (\cover ( trackGroupPrev, coverGroup, acc ) ->
                    let
                        trackGroupCurr =
                            cover.identifiedTrackCover
                                |> Tuple.first
                                |> .group
                                |> Maybe.map .name
                    in
                    if List.length coverGroup < 4 && (Maybe.isNothing trackGroupPrev || trackGroupCurr == trackGroupPrev) then
                        ( trackGroupCurr, coverGroup ++ [ cover ], acc )

                    else
                        ( trackGroupCurr, [ cover ], acc ++ [ coverGroup ] )
                )
                ( Nothing, [], [] )
                deps.covers

        coverGroups =
            b ++ [ a ]
    in
    { itemView = rowView itemDeps
    , itemHeight = InfiniteList.withVariableHeight (dynamicRowHeight viewportWidth)
    , containerHeight = round deps.viewportHeight - 262
    }
        |> InfiniteList.config
        |> InfiniteList.withCustomContainer infiniteListContainer
        |> (\config ->
                InfiniteList.view
                    config
                    deps.infiniteList
                    coverGroups
           )


infiniteListContainer :
    List ( String, String )
    -> List (Html msg)
    -> Html msg
infiniteListContainer styles =
    styles
        |> List.filterMap
            (\( k, v ) ->
                if k == "padding" then
                    Nothing

                else
                    Just (style k v)
            )
        |> List.append listStyles
        |> Html.div


compileItemDependencies : Dependencies -> ItemDependencies
compileItemDependencies deps =
    { cachedCovers = deps.cachedCovers
    , nowPlaying = deps.nowPlaying
    , sortBy = deps.sortBy
    }


listStyles : List (Html.Attribute msg)
listStyles =
    [ C.leading_tight
    , C.pl_5
    , C.pt_4
    ]
        |> String.join " "
        |> class
        |> List.singleton


dynamicRowHeight viewportWidth _ coverGroup =
    let
        containerWidth =
            -- TODO: replace 32 with actual horizontal padding
            min 768 (viewportWidth - 32)

        rowHeight =
            (containerWidth - 16) // 4 + (46 + 16)
    in
    let
        shouldRenderGroup =
            coverGroup
                |> List.head
                |> Maybe.andThen (.tracks >> List.head)
                |> Maybe.map (Tuple.first >> Tracks.shouldRenderGroup)
                |> Maybe.withDefault False
    in
    if shouldRenderGroup then
        42 + rowHeight

    else
        rowHeight



-- ROWS


rowView :
    ItemDependencies
    -> Int
    -> Int
    -> List Cover
    -> Html Msg
rowView itemDeps _ idx row =
    let
        maybeIdentifiers =
            row
                |> List.head
                |> Maybe.andThen (.tracks >> List.head)
                |> Maybe.map Tuple.first

        shouldRenderGroup =
            maybeIdentifiers
                |> Maybe.map Tracks.shouldRenderGroup
                |> Maybe.withDefault False
    in
    raw
        [ case ( shouldRenderGroup, maybeIdentifiers ) of
            ( True, Just identifiers ) ->
                chunk
                    [ C.minus_ml_4 ]
                    [ Scene.group { index = idx } identifiers ]

            _ ->
                nothing

        --
        , chunk
            [ C.flex, C.flex_wrap ]
            (List.map (itemView { clickable = True } itemDeps) row)
        ]



-- ITEMS


itemView : { clickable : Bool } -> ItemDependencies -> Cover -> Html Msg
itemView options deps cover =
    chunk
        [ C.antialiased
        , C.flex_shrink_0
        , C.font_semibold
        , C.mb_5
        , C.w_1_div_4
        ]
        [ coverView options deps cover
        , metadataView options deps cover
        ]


coverView : { clickable : Bool } -> ItemDependencies -> Cover -> Html Msg
coverView { clickable } { cachedCovers, nowPlaying } cover =
    let
        maybeBlobUrlFromCache =
            cachedCovers
                |> Maybe.withDefault Dict.empty
                |> Dict.get cover.key

        hasBackgroundImage =
            Maybe.isJust maybeBlobUrlFromCache

        nowPlayingId =
            Maybe.unwrap "" (.identifiedTrack >> Tuple.second >> .id) nowPlaying

        bgOrDataAttributes =
            case maybeBlobUrlFromCache of
                Just blobUrl ->
                    [ A.style "background-image" ("url('" ++ blobUrl ++ "')")
                    ]

                Nothing ->
                    if Maybe.isJust cachedCovers then
                        let
                            track =
                                Tuple.second cover.identifiedTrackCover
                        in
                        [ A.attribute "data-key" cover.key
                        , A.attribute "data-focus" cover.focus
                        , A.attribute "data-filename" cover.trackFilename
                        , A.attribute "data-path" track.path
                        , A.attribute "data-source-id" track.sourceId
                        , A.attribute "data-various-artists" (ifThenElse cover.variousArtists "t" "f")
                        ]

                    else
                        []
    in
    chunk
        [ C.h_0
        , C.mr_5
        , C.pt_full
        , C.relative
        , C.select_none

        --
        , ifThenElse clickable C.cursor_pointer C.cursor_default
        ]
        [ brick
            (List.append
                bgOrDataAttributes
                (if clickable then
                    [ E.onClick (TracksMsg <| SelectCover cover)
                    , Mouse.onContextMenu (showCoverMenu cover)
                    ]

                 else
                    []
                )
            )
            [ C.absolute
            , C.bg_cover
            , C.bg_gray_300
            , C.mb_5
            , C.inset_0
            , C.rounded_md
            , C.shadow

            -- Dark mode
            ------------
            , C.dark__bg_white_025
            ]
            [ if not hasBackgroundImage then
                chunk
                    [ C.absolute
                    , C.left_half
                    , C.minus_translate_x_half
                    , C.minus_translate_y_half
                    , C.text_gray_400
                    , C.top_half
                    , C.transform

                    -- Dark mode
                    ------------
                    , C.dark__text_base01
                    ]
                    [ Icons.album 26 Inherit ]

              else
                nothing

            -- Now playing?
            , if List.member nowPlayingId cover.trackIds then
                chunk
                    [ C.absolute
                    , C.bottom_0
                    , C.mb_3
                    , C.mr_3
                    , C.right_0
                    , C.text_white
                    ]
                    [ Icons.headset 16 Inherit ]

              else
                nothing
            ]
        ]


metadataView : { clickable : Bool } -> ItemDependencies -> Cover -> Html Msg
metadataView { clickable } { cachedCovers, sortBy } cover =
    let
        { identifiedTrackCover } =
            cover

        ( _, track ) =
            identifiedTrackCover
    in
    brick
        (if clickable then
            [ E.onClick (TracksMsg <| SelectCover cover)
            , Mouse.onContextMenu (showCoverMenu cover)
            ]

         else
            []
        )
        [ C.minus_mt_5
        , C.mr_5
        , C.pt_2
        , C.tracking_tad_closer

        --
        , ifThenElse clickable C.cursor_pointer C.cursor_default
        ]
        [ chunk
            [ C.mt_px
            , C.pt_px
            , C.truncate
            ]
            [ case sortBy of
                Album ->
                    text track.tags.album

                Artist ->
                    text track.tags.artist

                _ ->
                    nothing
            ]

        --
        , chunk
            [ C.mt_px
            , C.pt_px
            , C.text_base05
            , C.text_xs
            , C.truncate
            ]
            [ case sortBy of
                Album ->
                    if cover.variousArtists then
                        text "Various Artists"

                    else
                        text track.tags.artist

                Artist ->
                    text track.tags.title

                _ ->
                    nothing
            ]
        ]
