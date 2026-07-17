package com.example.spotitandroid.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.navigation.NavController

@Composable
fun AccountView(navController: NavController){
    Column {
        Button(onClick = {navController.navigate("home")}) {
            Text("home")
        }

        Text("Player Profile")
    }
}