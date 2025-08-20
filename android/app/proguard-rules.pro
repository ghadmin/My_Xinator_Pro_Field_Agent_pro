 ## Flutter wrapper
 -keep class io.flutter.app.** { *; }
 -keep class io.flutter.plugin.** { *; }
 -keep class io.flutter.util.** { *; }
 -keep class io.flutter.view.** { *; }
 -keep class io.flutter.** { *; }
 -keep class io.flutter.plugins.** { *; }
 -keep class com.google.firebase.** { *; }
 # Keep Clearent SDK classes
-keep class com.clearent.** { *; }
-keep class com.idt.** { *; }
-keep class com.github.universalcardreader.** { *; }

# Keep annotations and listeners
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.clearent.lib.listener.* <methods>;
}

# Keep native methods
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Prevent obfuscation of serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
 -dontwarn io.flutter.embedding.**
 -ignorewarnings