AddCSLuaFile()
PArmor = {}
include("ballistics.lua")

local VERSION = "0.1.0"
print("PArmor " .. VERSION .. " loaded!")

if SERVER then return end