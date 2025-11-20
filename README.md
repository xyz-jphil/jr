# Java Jar Runner - Smart java/javaw Launcher

A lightweight Windows executable that intelligently chooses between `java.exe` and `javaw.exe` based on execution context.

## Features

- **Smart Execution**: Automatically uses `java.exe` when run from console/terminal (shows output) and `javaw.exe` when double-clicked (no console window)
- **Auto-detection**: Finds Java installation from PATH environment variable
- **Override Support**: Allows specifying custom Java installation via `--java-home` parameter
- **Argument Forwarding**: Passes all arguments and exit codes transparently
- **Error Reporting**: Clear error messages with GUI dialogs when issues occur

## Building

### Option 1: MinGW GCC (Recommended)

```batch
test-scripts\build-mingw.bat
```

Requirements:
- MinGW GCC in PATH

### Option 2: Microsoft Visual C++

```batch
test-scripts\build-msvc.bat
```

Requirements:
- Visual Studio installed
- Run from "Developer Command Prompt for VS" OR have `devcmd.bat` in PATH

Both methods produce `jarrunner.exe` in the project root.

## Usage

### Basic Usage

```batch
jarrunner.exe myapp.jar
```

When double-clicked from Explorer, this runs with `javaw.exe` (no console).
When run from terminal, this runs with `java.exe` (console output visible).

### With Arguments

```batch
jarrunner.exe myapp.jar --arg1 value1 --arg2 value2
```

### Specifying Java Location

```batch
jarrunner.exe --java-home=C:\Java\jdk-21 myapp.jar
```

Or with space separator:

```batch
jarrunner.exe --java-home C:\Java\jdk-21 myapp.jar
```

Quoted paths are supported:

```batch
jarrunner.exe --java-home="C:\Program Files\Java\jdk-21" myapp.jar
```

## How It Works

1. **Console Detection**: Uses Windows API to detect if the process has an attached console
   - `AttachConsole(ATTACH_PARENT_PROCESS)` - tries to attach to parent console
   - `GetConsoleMode()` - checks if console already exists

2. **Java Selection**:
   - Console detected → uses `java.exe`
   - No console → uses `javaw.exe`

3. **Java Location**:
   - If `--java-home` provided → uses `%JAVA_HOME%\bin\java[w].exe`
   - Otherwise → searches PATH environment variable

4. **Execution**:
   - Constructs command: `"path\to\java.exe" -jar yourapp.jar [args]`
   - Uses `CreateProcessA()` with handle inheritance for proper I/O
   - Waits for completion and returns the same exit code

## Use Cases

1. **JAR File Associations**: Set `.jar` files to open with `jarrunner.exe` for smart console handling
2. **Desktop Shortcuts**: Create shortcuts that work both ways (console and GUI)
3. **Batch Scripts**: Use in automation where you need proper exit codes
4. **Multi-Java Environments**: Easily test JARs with different Java versions using `--java-home`

## Technical Details

- **Language**: C (Windows API)
- **Size**: ~15-20 KB (with optimization and stripping)
- **Subsystem**: Windows (not console, to enable GUI detection)
- **Dependencies**: kernel32.dll, user32.dll (standard Windows libraries)

## Error Handling

The launcher provides clear error messages for:
- Java not found in PATH
- Invalid `--java-home` path
- Missing JAR file argument
- Process creation failures

All errors are shown via `MessageBox` for visibility in both console and GUI contexts.

## License

This is a utility tool for Java application deployment on Windows.
