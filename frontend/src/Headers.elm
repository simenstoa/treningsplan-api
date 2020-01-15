module Headers exposing (mainHeader, paragraphHeader, smallHeader, smallParagraphHeader)

import Element exposing (padding, text)
import Element.Font
import Element.Region exposing (heading)
import Fonts


mainHeader : String -> Element.Element msg
mainHeader header =
    Element.paragraph [ Element.Font.size 60, heading 1, padding 20, Fonts.heading ]
        [ text <|
            header
        ]


smallHeader : String -> Element.Element msg
smallHeader header =
    Element.paragraph [ Element.Font.size 40, heading 2, padding 20, Fonts.heading ]
        [ text <|
            header
        ]


paragraphHeader : String -> Element.Element msg
paragraphHeader header =
    Element.paragraph [ heading 3, Element.Font.size 30, Fonts.heading ]
        [ text <|
            header
        ]


smallParagraphHeader : String -> Element.Element msg
smallParagraphHeader header =
    Element.paragraph [ heading 4, Element.Font.size 22, Fonts.heading ]
        [ text <|
            header
        ]
