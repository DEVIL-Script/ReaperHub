-- DEVIL Hub Premium Whitelist with AES-256-CBC Encryption
-- Format: [encrypted_user_id] = {discordId = encrypted_discord_id, active = boolean}
-- Decryption key and IV are in the client-side Lua script

local DiscordWhitelist = {
    ["e175606e25367936196e9cb14d679b38"] = {discordId = "6f7532beaf4bc744ceb89b2816d345ca9abe60af1edae23998c3c67cae8c3605", active = true}
}

return DiscordWhitelist