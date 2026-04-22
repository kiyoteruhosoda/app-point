# Keep FileProvider and XML parser related classes to prevent
# IncompatibleClassChangeError in release obfuscated builds.
-keep public class androidx.core.content.FileProvider { *; }

-keep class android.content.res.XmlBlock { *; }
-keep class android.content.res.XmlBlock$Parser { *; }
-keep class android.content.res.XmlResourceParser { *; }
-keep class org.xmlpull.** { *; }

-keepclassmembers class **.R$xml {
    public static *;
}
-keep public class **.R$xml

-keepnames class * implements android.os.Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
