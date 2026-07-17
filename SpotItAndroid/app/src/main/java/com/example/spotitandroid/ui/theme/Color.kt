package com.example.spotitandroid.ui.theme

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Brush

val Purple80 = Color(0xFFD0BCFF)
val PurpleGrey80 = Color(0xFFCCC2DC)
val Pink80 = Color(0xFFEFB8C8)

val Purple40 = Color(0xFF6650a4)
val PurpleGrey40 = Color(0xFF625b71)
val Pink40 = Color(0xFF7D5260)

// custom colors ;)
val RachaelsPink = Color(red = 1f, green = 0.7176f, blue = 0.8745f) // baby pink
val PennStatePink = Color(red = 0.737f, green = 0.125f, blue = 0.294f) // penn states og color
val RachaelsRed = Color(red = 0.3765f, green = 0f, blue = 0.0431f) // dark red
val RachaelsLavender = Color(red = 0.6745f, green = 0.5529f, blue = 0.8078f) // lavender
val RachaelsBlue = Color(red = 0.588f, green = 0.745f, blue = 0.902f) // baby blue
val RachaelsNavy = Color(red = 0f, green = 0.118f, blue = 0.267f) // navy blue current color
val RachaelPurple = Color(red = 0.286f, green = 0.114f, blue = 0.439f) // dark purple

// gradients
val RachaelsRedGradient = Brush.linearGradient(
    colors = listOf(
        Color(red = 0.3765f, green = 0f, blue = 0.0431f),
        Color(red = 0.4667f, green = 0f, blue = 0.0745f),
        Color(red = 0.7176f, green = 0f, blue = 0.1294f)
    )
)

val RachaelsGradientBluetoLav = Brush.linearGradient(
    colors = listOf(
        RachaelsBlue,
        RachaelsLavender
    )
)