# What is Gremlin?

Gremlin is a _free_ media import framework for iOS, used by popular products 
such as Celeste, iFile, Safari Download Manager and YourTube.

### How do I use it?

If you are developing a free and open source application, you can use Gremlin 
to perform media import, all you need to do is link against 
**Gremlin.framework** and call:

```objective-c
[Gremlin importFileAtPath:path];
```

Alternatively, you may use one of the other APIs defined in 
[`Gremlin.h`](https://github.com/yfrancis/gremlin/blob/master/framework/Gremlin.h)
More details on this feature will be made available soon.

### What can I do with it?

Gremlin is entirely plugin-based! What this means is that you can build an
importer plugin for any type of file targeting any destination of your choice. 
Gremlin comes pre-packaged with a document import plugin that allows you to 
import files to generic apps that declare file type support via LaunchServices.

If you require more fine-grained control, or your particular target does not 
support LaunchServices, you can build an import plugin for this purpose. Once 
installed your plugin will become automatically available to any application 
that uses Gremlin!

### License terms

Gremlin is licensed under a modified GPLv3 license. In addition to the terms 
imposed by GPLv3, you may not distribute or use Gremlin whether directly or 
indirectly for the purposes of financial gain without explicit written consent
of the author, Youssef Francis. It is important to note that this policy is
targeting only specific offenders, my intent is for Gremlin to be used by as 
many developers and users
as possible.

For questions regarding licensing, please email me.
