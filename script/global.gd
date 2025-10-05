extends Node

var gameStarted: bool

var playerBody: CharacterBody2D
var playerWeaponEquip: bool

var playerAlive: bool
var playerDamageZone: Area2D
var playerDamageAmount: int

var batDamageZone = null
var batDamageAmount = 0
