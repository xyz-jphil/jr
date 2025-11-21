# Java JAR Runner - Smart Launcher for Windows

A lightweight Windows executable (~20KB) that intelligently launches Java JAR files with optimal settings.

## Features

- **Smart Execution**: Automatically uses `java.exe` when run from console/terminal (shows output) and `javaw.exe` when double-clicked (no console window)
- **Auto-detection**: Finds Java installation from PATH environment variable
- **Override Support**: Allows specifying custom Java installation via `--java-home` parameter
- **AOT Cache Support**: Ahead-of-Time (AOT) compilation cache enabled by default for JDK 25+ (use `--disable-aot` to turn off)
- **Automatic Cache Management**: Detects JAR changes and automatically manages AOT cache files
- **Performance Timing**: Passes startup timing metrics to JVM for performance analysis
- **Argument Forwarding**: Passes all arguments and exit codes transparently
- **Error Reporting**: Clear error messages with GUI dialogs when issues occur

## Building

Build from source using Microsoft Visual C++:

```batch
build-win.bat
```

**Requirements:**
- Microsoft Visual C++ build tools (portable or full Visual Studio)
- Run from "Developer Command Prompt for VS" OR have `devcmd.bat` in PATH

**Note:** For portable MSVC build tools without full Visual Studio install, see [PortableBuildTools](https://github.com/Data-Oriented-House/PortableBuildTools) (archived but functional).

This produces the launcher executable in the project root.

## Usage

### Basic Usage

```batch
jarrunner.exe myapp.jar
```

**AOT is enabled by default** for JDK 25+. The first run creates an AOT cache file (e.g., `myapp.1A2B3C.4D5E6F.aot`) adjacent to the JAR. Subsequent runs automatically reuse the cache for ~90% faster startup.

When double-clicked from Explorer, runs with `javaw.exe` (no console).
When run from terminal, runs with `java.exe` (console output visible).

### With Arguments

```batch
jarrunner.exe myapp.jar --arg1 value1 --arg2 value2
```

### Disable AOT Cache

```batch
jarrunner.exe --disable-aot myapp.jar
```

Use this to skip AOT cache generation/usage (for older JDKs or debugging).

The AOT cache filename encodes the JAR's file size and modification time in base52, so when the JAR is updated, a new cache is automatically generated and old caches are cleaned up.

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

### Combined Usage

```batch
jarrunner.exe --java-home=C:\Java\jdk-25 myapp.jar --arg1 value1
```

AOT is enabled by default. To disable:
```batch
jarrunner.exe --disable-aot --java-home=C:\Java\jdk-21 myapp.jar
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

4. **AOT Cache Management** (if `--enable-aot` specified):
   - Calculates AOT cache filename: `<jarname>.<size_base52>.<modtime_base52>.aot`
   - Checks if cache exists for current JAR version
   - If exists: passes `-XX:AOTCache=<path>` to JVM
   - If not: passes `-XX:AOTCacheOutput=<path>` to create new cache
   - Automatically cleans up outdated AOT files from previous JAR versions

5. **Performance Timing**:
   - Records start time using high-resolution performance counter
   - Records time before JVM invocation
   - Passes timing data via `-Djarrunner.start.micros` and `-Djarrunner.beforejvm.micros`
   - Java code can read these properties to measure launcher overhead

6. **Execution**:
   - Constructs command: `"path\to\java.exe" [timing-props] [aot-cache] -jar yourapp.jar [args]`
   - Uses `CreateProcessA()` with handle inheritance for proper I/O
   - Waits for completion and returns the same exit code

## Use Cases

1. **JAR File Associations**: Set `.jar` files to open with `jarrunner.exe` for smart console handling
2. **Desktop Shortcuts**: Create shortcuts that work both ways (console and GUI)
3. **Batch Scripts**: Use in automation where you need proper exit codes
4. **Multi-Java Environments**: Easily test JARs with different Java versions using `--java-home`

## Testing

**Build test JAR first:**
```batch
cd test-scripts
build-test-jar.bat
```

**Performance testing with statistical analysis (5 runs each):**
```batch
cd test-scripts
GeneralAndAOTPerformanceTest.bat
```

This measures:
- Baseline performance (with --disable-aot flag)
- AOT cache creation (first run, AOT enabled by default)
- AOT cache usage (subsequent runs with ~90% faster startup)

**Quick comparison:**
```batch
cd test-scripts
QuickCompare.bat
```

Shows side-by-side timing for single runs.

## Technical Details

- **Language**: C (Windows API)
- **Size**: ~20 KB
- **Dependencies**: Standard Windows libraries (kernel32.dll, user32.lib)
- **Behavior**:
  - Console mode: Waits for process, returns exit code
  - GUI mode: Launches and exits immediately
