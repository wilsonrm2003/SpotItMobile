package com.example.spotitandroid.ui.screens

import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.NavController

@Composable
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
    Column{
        Text("Spot It! Mobile")

        Button(onClick = {navController.navigate("singleplayer")}) {
            Text("Singleplayer")
        }
        Button(onClick = {navController.navigate("multiplayer")}) {
            Text("Multiplayer")
        }

        Row{
            Button(onClick = {navController.navigate("leaderboard")}) {
                Text("Leaderboard")
            }

            Button(onClick = {navController.navigate("accountView")}) {
                Text("Profile")
            }
        }
    }
}