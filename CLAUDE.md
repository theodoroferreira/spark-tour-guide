# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
- Godot 4.3 game project (2D)
- Educational game for Brazilian children (8-12 years) to learn English
- GDScript programming language
- Set in Ijuí, RS, Brazil with local landmarks

## Code Style Guidelines
- Follow Godot's GDScript style guide
- Use PascalCase for classes/nodes (Player.gd, DialogBox.tscn)
- Use snake_case for variables and functions (current_scene, load_home_scene)
- Organize code in folders by function (scenes/, scripts/, assets/)
- Use inheritance for minigames (inherit from MinigameBase.gd)
- Document functions with brief comments
- Signals should use past tense (minigame_completed)

## Structure Conventions
- Scenes (.tscn) in scenes/ directory
- Scripts (.gd) in scripts/ directory
- Assets in assets/ directory (organized by type)
- Use autoload for singleton GameManager

## Testing & Running
- Test in Godot Editor with Play button
- Debug using Godot's built-in debugger
- Run scenes individually for testing specific components

## Best Practices
- Keep GameManager as central controller
- Emit signals for communication between objects
- Use _ready() for initialization
- Follow node/script organization in game_plan.md