/Warning: This is still a WIP/

The `indian` library provides unmanaged memory access and native function calling for Haxe targets - allowing Haxe code to interact with native platforms without the need of [any other] CFFI glue code.

### Targets support
 * c# (using unsafe code)
 * c++
 * neko (using helper library - slow)
 * java (optionally using sun.misc.Unsafe for memory manipulation)

Native function calling will be done through the platform's native support when possible. Otherwise, libffi will be used.
