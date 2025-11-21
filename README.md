# Java Runner (jr) - Make Your JARs Feel Like Native Windows Executables

A tiny Windows launcher (23 KB) that makes JAR files executable like native .exe files - with automatic console/GUI detection, JDK 25 AOT cache support, and simple configuration.

## What Makes jr Different?

**Make JARs truly executable without GraalVM complexity or jpackage bloat:**

1. **Execute JARs like native .exe files** - Set up Windows file association and PATHEXT, double-click JARs or run them by name from command line
2. **Automatic AOT cache (JDK 25+)** - 90% faster startup (20-30ms vs 200-300ms) with zero configuration
3. **Smart console detection** - Automatically uses java.exe (console) or javaw.exe (GUI) based on how you launch it
4. **Two modes**: Works as generic JAR launcher (no config needed) OR as dedicated app launcher with .jrc config files
5. **Tiny size** - 23 KB (with vcredist) or 193 KB standalone, vs 500 KB (Launch4j) or 50+ MB (jpackage)

**Key Features:**
- Automatic console/GUI detection (no manual configuration like Launch4j/WinRun4J)
- JDK 25 AOT cache support out of box (creates, uses, and cleans up cache automatically)
- Works without any config file (traditional mode) or with simple .jrc config (config mode)
- Command-line arguments override config settings
- Debug logging (opt-in only)
- Finds Java from PATH or use `--java-home` to specify custom JDK

## Download

**Pre-built executables are available in [GitHub Releases](../../releases):**

- **`jr-standalone.exe`** (193 KB) - **Recommended** - No dependencies, works everywhere
- **`jr.exe`** (23 KB) - Requires VC++ Redistributable 2015-2022

Download, rename if desired, and start using immediately!

## Building from Source

Build from source using Microsoft Visual C++:

```batch
build-win.bat
```

**Requirements:**
- Microsoft Visual C++ build tools (portable or full Visual Studio)
- Run from "Developer Command Prompt for VS" OR have `devcmd.bat` in PATH

**Note:** For portable MSVC build tools without full Visual Studio install, see [PortableBuildTools](https://github.com/Data-Oriented-House/PortableBuildTools) (archived but functional).

This produces both executables:
- `jr.exe` (23 KB, requires VC++ Redistributable)
- `jr-standalone.exe` (193 KB, no dependencies)

## Quick Start - Make JARs Executable System-Wide

The most powerful way to use jr is to make ALL jar files on your system executable like native .exe files:

### Step 1: Set Up File Association

Associate `.jar` files with `jr.exe`:

```batch
# Windows Registry approach (run as Administrator)
ftype jarfile="C:\path\to\jr.exe" "%1" %*
assoc .jar=jarfile
```

Or use Windows Settings:
- Right-click any `.jar` file → Open with → Choose another app
- Browse to `jr.exe` → Check "Always use this app" → OK

### Step 2: Add .JAR to PATHEXT (Optional but Recommended)

This allows running JARs by name without typing `.jar` extension:

```batch
# Add to System Environment Variables
setx PATHEXT "%PATHEXT%;.JAR"
```

Or manually:
- Open System Properties → Environment Variables
- Edit `PATHEXT` variable
- Append `;.JAR` to the end
- Original: `.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC`
- Updated: `.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.JAR`

**What this gives you:**

```batch
# Double-click JARs from Windows Explorer - they just work!
# (with automatic console/GUI detection and AOT caching)

# Run JARs from command line by name (if in PATH)
myapp.jar arg1 arg2

# Or even without .jar extension
myapp arg1 arg2

# Works everywhere, with automatic AOT speedup (JDK 25+)
```

**No more fragile batch files!** Your JARs become first-class citizens like .exe files.

## Usage

### Mode 1: Traditional Mode (Simple JAR Launcher)

Use `jr.exe` directly to launch any JAR file:

```batch
# Basic usage
jr.exe myapp.jar

# With arguments
jr.exe myapp.jar --arg1 value1 --arg2 value2

# Disable AOT cache
jr.exe --disable-aot myapp.jar

# Specify Java location
jr.exe --java-home=C:\Java\jdk-21 myapp.jar

# Combined
jr.exe --disable-aot --java-home=C:\Java\jdk-25 myapp.jar --verbose
```

**How it works:**
- When double-clicked from Explorer → runs with `javaw.exe` (no console)
- When run from terminal → runs with `java.exe` (console output visible)
- AOT cache enabled by default for faster subsequent launches

### Mode 2: Config Mode (With .jrc Configuration File)

For applications you run frequently, create a configuration file:

#### Step 1: Create Configuration

```batch
# Generate template config file
jr.exe --create-config myapp.jar

# This creates jr.jrc in the same directory
```

#### Step 2: Rename Executable (Optional)

```batch
# Rename jr.exe to match your application
copy jr.exe myapp.exe
```

#### Step 3: Customize Configuration

The generated `myapp.jrc` file (or `jr.jrc` if not renamed):

```properties
# Java Runner Configuration (.jrc format)
# Lines starting with # are comments
# Format follows WinRun4J/jpackage conventions

# VM arguments (passed before -jar, launcher auto-injects AOT flags here)
vm.args=-Xmx512m -Xms128m -Dapp.mode=production

# Java arguments (everything after VM args: -jar, -cp, class name, etc.)
java.args=-jar myapp.jar

# Application arguments (passed to your main method)
app.args=--config myconfig.xml --verbose

# AOT cache control (optional, default: true)
aot=true

# Debug logging (optional, only used when specified)
log.file=myapp.log
log.level=info
log.overwrite=false
```

#### Step 4: Run

```batch
# Simply run the renamed executable
myapp.exe

# Command-line arguments are appended to config settings
myapp.exe --extra-arg value
```

### Configuration File Details

#### Supported Keys

| Key | Description | Example |
|-----|-------------|---------|
| `vm.args` | JVM arguments (before `-jar`) | `-Xmx512m -Xms128m -Dkey=value` |
| `java.args` | Java arguments (`-jar`, `-cp`, main class) | `-jar myapp.jar` or `-cp lib/*:app.jar com.Main` |
| `app.args` | Application arguments (after jar/class) | `--config app.xml --verbose` |
| `aot` | Enable/disable AOT cache | `true` or `false` |
| `log.file` | Debug log file path | `myapp.log` |
| `log.level` | Log verbosity | `info`, `warning`, `error`, `none` |
| `log.overwrite` | Overwrite log on each run | `true` or `false` (default: append) |

#### Complex Java Arguments Examples

**With classpath:**
```properties
java.args=-cp lib/*;app.jar com.example.Main
```

**With module system:**
```properties
java.args=-p mods -m com.example.myapp/com.example.Main
```

**Multiple JARs:**
```properties
java.args=-cp app.jar;lib/dep1.jar;lib/dep2.jar com.example.Main
```

#### Priority System

Settings are applied in this order (later overrides earlier):
1. Config file defaults
2. `.jrc` file settings
3. Command-line arguments

Example:
```properties
# In myapp.jrc
app.args=--mode production
```

```batch
# Running with additional args
myapp.exe --debug

# Final command will have: --mode production --debug
```

### AOT Cache Management

**How AOT Works:**

The launcher automatically manages AOT (Ahead-of-Time) cache files for JDK 25+:

1. **First Run**: Creates AOT cache file (e.g., `myapp.g2.4ZBZgN.aot`)
   - Filename encodes JAR size and modification time
   - Takes a bit longer to start

2. **Subsequent Runs**: Reuses existing cache
   - ~90% faster startup
   - Automatic cache invalidation when JAR changes

3. **JAR Update**: Detects changes automatically
   - Old cache files are cleaned up
   - New cache created on next run

**AOT Cache Filename Format:**
```
<jarname>.<size_base52>.<modtime_base52>.aot
```

**Control AOT:**

```batch
# Disable for a single run (command-line)
jr.exe --disable-aot myapp.jar

# Disable permanently (config file)
aot=false

# Enable explicitly (config file, overrides default)
aot=true
```

### Debug Logging

Logging is **opt-in only** and never happens automatically:

```properties
# Enable logging in .jrc file
log.file=myapp.log
log.level=info
log.overwrite=false
```

**Log Content:**
```
========================================
Java Runner Log - 2025-11-21 17:05:06
========================================
[INFO] Launcher started: myapp.exe
[INFO] Execution mode: Console
[INFO] Java executable: java.exe
[INFO] AOT enabled: true
[INFO] Found Java in PATH: C:\Java\jdk-25\bin\java.exe
[INFO] Using config-based mode
[INFO] Creating new AOT cache: myapp.g2.4ZBZgN.aot
[INFO] Final command: "C:\Java\jdk-25\bin\java.exe" -Djarrunner.start.micros=0 ...
[INFO] Java process started successfully (PID: 2680)
[INFO] Java process exited with code: 0
========================================
```

**Perfect for troubleshooting:**
- Configuration parsing
- Java detection
- AOT decisions
- Full command line executed
- Exit codes

## Use Cases

**Primary Use Case (Recommended):**
1. **System-wide JAR execution** - Set up file association + PATHEXT, make ALL jars executable like .exe files (with automatic AOT!)

**Other Use Cases:**
2. **Branded Application Launchers** - Rename `jr.exe` to `yourapp.exe`, add `.jrc` config, distribute together
3. **Multi-Java Environments** - Test JARs with different Java versions using `--java-home`
4. **Complex Launch Configurations** - Use `.jrc` files for applications requiring specific JVM settings
5. **Desktop Shortcuts** - Create shortcuts that work both ways (console and GUI)
6. **Batch Scripts** - Use in automation where you need proper exit codes

## Testing

**Build test JAR first:**
```batch
cd test-scripts
build-test-jar.bat
```

**Run comprehensive tests:**
```batch
cd test-scripts
TestJR.bat
```

This tests:
- Help display
- Traditional JAR launch
- Config file creation
- Config-based mode
- Logging functionality
- AOT disable flag

**Quick manual tests:**
```batch
# Test help
jr.exe

# Test traditional mode
jr.exe test-scripts\TestStartupTiming.jar

# Test config creation
jr.exe --create-config test-scripts\TestStartupTiming.jar

# Test config mode
copy jr.exe mytest.exe
copy test-scripts\TestStartupTiming.jar mytest.jar
# (edit mytest.jrc)
mytest.exe
```

## Technical Details

- **Language**: C (Windows API)
- **Size**: ~20 KB
- **Dependencies**: Standard Windows libraries (kernel32.dll, user32.lib)
- **Config Format**: Simple key=value properties format with comment support
- **File Extension**: `.jrc` (Java Runner Config)
- **Behavior**:
  - Console mode: Waits for process, returns exit code
  - GUI mode: Launches and exits immediately
- **Config File Naming**: Must match executable name (e.g., `myapp.exe` → `myapp.jrc`)
- **Config Discovery**: Checks for `<exename>.jrc` in same directory as executable

## Configuration Format Compatibility

The `.jrc` format follows industry standards:
- Similar to **WinRun4J** INI format (but simplified)
- Compatible with **jpackage** launcher properties file conventions
- Portable across Windows, Linux, and macOS (C code is cross-platform ready)

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

4. **Config File Loading**:
   - Checks for `<exename>.jrc` in same directory
   - If found: parses configuration
   - If not found: falls back to traditional mode

5. **AOT Cache Management** (if enabled):
   - Calculates AOT cache filename: `<jarname>.<size_base52>.<modtime_base52>.aot`
   - Checks if cache exists for current JAR version
   - If exists: passes `-XX:AOTCache=<path>` to JVM
   - If not: passes `-XX:AOTCacheOutput=<path>` to create new cache
   - Automatically cleans up outdated AOT files from previous JAR versions

6. **Performance Timing**:
   - Records start time using high-resolution performance counter
   - Records time before JVM invocation
   - Passes timing data via `-Djarrunner.start.micros` and `-Djarrunner.beforejvm.micros`
   - Java code can read these properties to measure launcher overhead

7. **Execution**:
   - Constructs command: `"path\to\java.exe" [timing-props] [vm.args] [aot-cache] [java.args] [app.args] [cmdline-args]`
   - Uses `CreateProcessA()` with handle inheritance for proper I/O
   - Waits for completion and returns the same exit code

## Examples

### Example 1: Simple Web Server

```batch
# Create launcher
copy jr.exe webserver.exe

# Create webserver.jrc
vm.args=-Xmx1g -Xms256m
java.args=-jar webserver.jar
app.args=--port 8080 --host 0.0.0.0
aot=true
log.file=webserver.log
log.level=info

# Run
webserver.exe
```

### Example 2: Development Tool with Custom JDK

```batch
# Create launcher
copy jr.exe devtool.exe

# Create devtool.jrc
vm.args=-Xmx512m -Ddev.mode=true
java.args=-jar devtool.jar
aot=false
log.file=devtool-debug.log
log.level=info
log.overwrite=true
```

Run with custom JDK:
```batch
devtool.exe --java-home=C:\Java\jdk-21
```

### Example 3: Classpath-Based Application

```batch
# Create myapp.jrc
vm.args=-Xmx2g
java.args=-cp lib/*;app.jar com.example.Main
app.args=--config production.xml
```

## Comparison with Other Tools

**vs Launch4j / WinRun4J:**
- Much smaller (23 KB vs 500 KB for Launch4j)
- Automatic AOT cache support (90% faster startup with JDK 25+)
- Automatic console/GUI detection (no manual config needed)
- Works without config files (can also work with config when needed)
- Actively maintained (Launch4j: 2017, WinRun4J: 2018, both inactive)

**vs jpackage (bundled JRE approach):**
- 2000x smaller (doesn't bundle JRE - 23 KB vs 50+ MB)
- Users can use any Java version they want
- Easier updates (just replace JAR, no need to rebuild entire package)
- Still gets AOT performance benefits with JDK 25+

**vs GraalVM native-image:**
- No complex build process or compatibility issues
- Much faster build times (just compile C, not whole Java app)
- Smaller executables for simple use cases
- Flexibility to swap Java versions
- Works with all Java code (no reflection/JNI limitations)

**The Philosophy:**
jr doesn't try to hide that your app is Java. It embraces it. It just makes the execution experience feel native - double-click to run, automatic console handling, fast startup with AOT, executable from command line. Best of both worlds.

### Performance Metrics

With JDK 25+ and AOT enabled:

```
First Run (creating AOT cache):
  Startup: ~200-300ms (one-time cost)

Subsequent Runs (with AOT cache):
  Startup: ~20-30ms (90% faster!)

Without AOT:
  Startup: ~150-200ms (standard)
```

**Launcher Overhead:**
- jr overhead: ~2-3ms (measured via performance counters)
- Direct java.exe: 0ms baseline
- **Overhead is negligible** - AOT gains far outweigh it!

## Privacy & Security

- **No Embedded Paths**: Executable doesn't contain build machine paths
- **Portable**: Can be moved between directories/systems
- **No Telemetry**: No data collection or phone-home features
- **Source Available**: Full C source code provided for review
- **Signing**: Unsigned by default; sign with your own certificate for distribution

## License

This project is open source. See license file for details.

## Contributing

Contributions welcome! Please ensure:
- Code follows existing style
- Test on Windows 10/11
- Update documentation for new features

## Support

For issues, questions, or feature requests, please file an issue in the repository.
