### Pump.Fun Bundler

Welcome to the Open-Source **Pump.Fun Bundler** – your ultimate solution for bundling on Pump.Fun with advanced profile creation and anti-bubble maps!

This open-source and free tool offers the most efficient self-bundling script for Pump.Fun, enabling you to launch a token with 20 different wallets and profiles. 

Enjoy launches that are completely bubble maps-proof and anti-Photon SB marks.

For more details, join our Discord at [discord.gg/solana-scripts](https://discord.gg/solana-scripts)



## Features

### Seamless UI
- **💊 Intuitive User Interface:** Experience a straightforward and completely automatic user interface designed for ease of use and efficiency.

### Advanced Profile Creation
- **🧑 Random Profiles:** Automatically generate profiles for each wallet to ensure maximum authenticity, with each wallet holding different random tokens.

### Custom LUT Program
- **🔥 Custom LUT Program:** Leverage our custom Look-Up Table (LUT) program to optimize your launch strategies.

### Automatic Supply Deviation
- **🚨 Supply Management:** Automatically manage supply deviations for smooth and efficient launches.

### Custom Configurable Buyers
- **🔔 Configurable Buyers:** Customize and configure up to 20 different keypair buyers for personalized launch strategies.

### Unmatched Performance
- **🤖 Performance and Speed:** Benefit from unparalleled performance, stability, and speed with our tool.

### Custom Onchain Program
- **📂 Onchain Integration:** Seamlessly integrate and operate with our bespoke onchain program.

### Complex Sell Strategies
- **💸 Sell Strategies:** Implement complex percentage-based sell strategies across all keypairs simultaneously.

### And Much More!
- Discover even more features designed to optimize your launch experience and help you profit from your Pump.Fun launches.

## Installation

To get started with the Pump.Fun Launch Bundle Tool, follow these steps:

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/cicero/pumpfun-bundler.git
    ```

2. **Navigate to the Project Directory:**
    ```bash
    cd pumpfun-launcher
    ```

3. **Install Dependencies:**
    ```bash
    npm install
    ```

4. **Set Up Environment Variables:**
    Create a `.env` file in the project directory and add your configuration details:
    ```plaintext
    SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
    PRIVATE_KEY=<your-private-key-bs58>
    ```

5. **Start the Application:**
    ```bash
    npm start
    ```

## Usage

1. **Configure Buyers and Launch Settings:**
    Use the intuitive UI to configure your buyers and launch settings.

2. **Start the Bundling Process:**
    Initiate the bundling process and let the tool handle the rest automatically.

3. **Profit:**
    Sit back and profit from your successful Pump.Fun launches!

## Roblox Studio MCP Integration

Du kannst Claude Code direkt mit Roblox Studio verbinden, um Skripte zu lesen, zu schreiben und das Spiel-Hierarchy abzufragen.

### Voraussetzungen

1. **Roblox Studio MCP Plugin installieren:**
   - Öffne Roblox Studio
   - Gehe zu **Plugins > Manage Plugins**
   - Suche nach **"Claude MCP"** oder **"MCP Server"** und installiere es
   - Das Plugin startet automatisch einen lokalen Server auf `http://localhost:3000`

2. **Claude Code konfigurieren:**
   - Die Datei `.mcp.json` ist bereits im Projekt enthalten und konfiguriert Claude Code automatisch:
     ```json
     {
       "mcpServers": {
         "roblox-studio": {
           "type": "sse",
           "url": "http://localhost:3000/sse"
         }
       }
     }
     ```

### Verwendung

1. Starte Roblox Studio und öffne dein Projekt
2. Stelle sicher, dass das MCP Plugin aktiv ist (grünes Symbol in der Plugin-Leiste)
3. Starte Claude Code in diesem Verzeichnis:
   ```bash
   claude
   ```
4. Claude kann jetzt direkt mit Roblox Studio kommunizieren:
   - Skripte lesen und bearbeiten
   - Objekte in der Workspace abfragen
   - Änderungen live in Studio einspielen

### Hinweis

Der MCP Server muss laufen, bevor du Claude Code startest. Wenn der Server nicht verfügbar ist, funktionieren die Roblox Studio Tools nicht.

---

## Support and Contributions

As an open-source project, we welcome contributions and feedback. If you have any questions or need assistance, please contact us on Telegram at @benorizz0.

Enjoy seamless, efficient, and profitable launches with the Pump.Fun Launch Bundle Tool!
