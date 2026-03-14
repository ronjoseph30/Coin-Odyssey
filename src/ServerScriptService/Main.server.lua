print("Game server started!")

game.Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the game")
end)