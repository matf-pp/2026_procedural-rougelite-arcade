<div align="center">
<pre>
██╗     ██╗   ██╗███╗   ██╗ █████╗ ███████╗ ██████╗ ██╗     
██║     ██║   ██║████╗  ██║██╔══██╗██╔════╝██╔═══██╗██║     
██║     ██║   ██║██╔██╗ ██║███████║███████╗██║   ██║██║     
██║     ██║   ██║██║╚██╗██║██╔══██║╚════██║██║   ██║██║     
███████╗╚██████╔╝██║ ╚████║██║  ██║███████║╚██████╔╝███████╗
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝
</pre>
</div>

<h1 align="center">LunaSol</h1>

  <p align="center">
    A procedural arcade-style roguelike made with Love2D and Lua.
  </p>

  <p align="center">
    <img src="display%20visuals/gameplay-maze.png" alt="LunaSol gameplay — navigating a procedurally generated maze" width="800">
  </p>

  ---

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/5fc6748d7264446a9da19e6142b03e63)](https://app.codacy.com/gh/matf-pp/2026_procedural-rougelite-arcade/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

  ## About

  Student project for the course
  [Programming Paradigms](https://www.programskijezici.matf.bg.ac.rs/ProgramskeParadigmeI.html#0_tab)
  at the Faculty of Mathematics, University of Belgrade.

  ### Authors

  - Aleksandar Djordjevic
  - Milan Torbica
  - Tarik Ramadani

  ## Gameplay

  Roaming **the lobby**, the hub you return to between runs:

  <p align="center">
    <img src="display%20visuals/clip1.gif" alt="Roaming the lobby" width="600">
  </p>

  A sneak peek at **The Shop**, a between-runs hub currently in development:

  <p align="center">
    <img src="display%20visuals/the-shop.png" alt="The Shop" width="600">
  </p>

  ## Game Flow

  The game is driven by a lightweight state manager. Each screen is a registered
  state, and transitions between them are animated with our own **sunshine** library.

  ```mermaid
  stateDiagram-v2
      [*] --> menu
      menu --> lobby

      lobby --> playing
      lobby --> shop
      shop --> lobby

      playing --> pause
      pause --> playing
      pause --> menu

      playing --> death
      death --> playing
      death --> menu

      playing --> victory
      victory --> playing

      playing --> win
      win --> lobby
  ```

  The **sunshine** transitions (iris and fade) in motion between states:

  <p align="center">
    <img src="display%20visuals/clip2.gif" alt="Sunshine iris and fade transitions between states" width="600">
  </p>

  ## Built With

  - [Lua](https://www.lua.org/)
  - [Love2D](https://love2d.org/)

  ## Tools used:

  - [Aseprite](https://www.aseprite.org)
  - [BeepBox](https://www.beepbox.co)
  - [Visual Studio Code](https://www.code.visualstudio.com)

  ## Running the Game

  Download the latest executable for your system from the Releases page.

  > Releases are not available yet.

  ## Development Setup

  > If you just want to play the game, see [Running the Game](#running-the-game) above.

  ### Prerequisites

  - [Love2D](https://love2d.org/) — includes LuaJIT, a just-in-time compiler for Lua. We mainly used Visual Studio Code for development,
  with the Lua and Love2D Support extensions by sumneko and Pixelbyte Studios.

  ### Running Locally
  1. Install Love2D.
  2. *(Optional)* Add Love2D to your PATH:

  ```bash
  export PATH="$PATH:/path/to/love"
  ```

  3. Run the game from the project root:

  ```bash
  love .
  ```

  ---
  License

  TODO
