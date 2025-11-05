package com.example.ktest

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform