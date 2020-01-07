module Fonts exposing (body, heading)

import Element.Font


heading =
    Element.Font.family [ Element.Font.typeface "Lora", Element.Font.typeface "Times New Roman", Element.Font.serif ]


body =
    Element.Font.family [ Element.Font.typeface "Open Sans", Element.Font.typeface "Roboto", Element.Font.sansSerif ]
