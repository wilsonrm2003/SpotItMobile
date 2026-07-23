package com.example.spotitandroid.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.ManageAccounts
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.spotitandroid.ui.theme.RachaelsBackground
import com.example.spotitandroid.ui.theme.RachaelsNavy
import com.example.spotitandroid.ui.theme.RachaelsPink
import com.example.spotitandroid.ui.theme.RachaelsRed
import com.example.spotitandroid.ui.theme.rachaelsFontStyleMode


@Composable
@Preview
fun MainView() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = "home") {
        composable("home") {
            HomeScreen(navController = navController)
        }
        composable("singleplayer") {
            SingleplayerGame(navController = navController)
        }
        composable("multiplayer") {
            MultiplayerLobby(navController = navController)
        }
        composable("leaderboard") {
            LeaderboardScreen(navController = navController)
        }

        composable("accountView") {
            AccountView(navController = navController)
        }
    }

}


@Composable
fun HomeScreen(navController: NavController) {
    val isDark = isSystemInDarkTheme()
    RachaelsBackground {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ){

            Spacer(modifier = Modifier.weight(1f))

            Text("Spot It! Mobile", style = rachaelsFontStyleMode(size = 48))

            Spacer(modifier = Modifier.weight(1f))

            Button(
                onClick = {navController.navigate("singleplayer") },
                shape = RoundedCornerShape(50),
                colors= ButtonDefaults.buttonColors(
                    containerColor = if (isDark) RachaelsNavy else RachaelsPink
                )
            ){
                Text("Singleplayer", style = rachaelsFontStyleMode(size = 30))
            }

            Spacer(modifier = Modifier.weight(0.3f))

            Button(
                onClick = {navController.navigate("multiplayer") },
                shape = RoundedCornerShape(50),
                colors= ButtonDefaults.buttonColors(
                    containerColor = if (isDark) RachaelsNavy else RachaelsPink
                )
            ){
                Text("Multiplayer", style = rachaelsFontStyleMode(size = 30))
            }

            Spacer(modifier = Modifier.weight(1f))

            Row (
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 40.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .background(
                            color = if (isDark) RachaelsNavy else RachaelsPink,
                            shape = CircleShape
                        )
                        .clickable { navController.navigate("leaderboard") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.EmojiEvents,
                        contentDescription = "Leaderboard",
                        tint = if (isDark) RachaelsPink else RachaelsRed,
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .background(
                            color = if (isDark) RachaelsNavy else RachaelsPink,
                            shape = CircleShape
                        )
                        .clickable { navController.navigate("accountView") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.ManageAccounts,
                        contentDescription = "Profile",
                        tint = if (isDark) RachaelsPink else RachaelsRed,
                        modifier = Modifier.size(40.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1f))
        }
    }
}
