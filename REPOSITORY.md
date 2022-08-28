# Create your own MaterialHunter repository
> The MaterialHunter repository is a final json file on the server that stores a list with chroot headers nested inside. For example -> [here](https://raw.githubusercontent.com/Mirivan/dev-root-project/main/.materialrepo)
----
- The repository includes one main key - chorot number in the list, and the keys nested in it - headers. There can be multiple main keys, but they must all include headers (see example above)!
- Headers:
    - Includes three required keys: «name», «file» or «url» and «author» (all keys are necessarily)
    - The «name» can be any, from any number of characters, **preferably** not exceeding 24 characters
    - «file» - is responsible for the location of the file on the server, the path is specified from the repository file. By the way, if the «url» is specified, then the «file» key will not be read! Example:
        > Repo url (which one did you use in MaterialHunter) is «https://github.com/Mirivan/dev-root-project/blob/main/chroots/mhsettings.json»
        
        > File name is: «chroot.tar.gz»
        
        - In code:
        ```
        {
            "0": {
                "Chroot name",
                "url": "",
                "file": "chroot.tar.gz",
                ...
            },
            "1": {...
        }
        ```
        
        > Then the key «file» will guide us along the way: «https://github.com/Mirivan/dev-root-project/blob/main/chroots/chroot.tar.gz»
    
    - «url» - key, which contains a direct link to the archive with chroot. Must be gz or xz compresion. Let me remind you that if this key is specified, then the «file» key will not be read by the MaterialHunter client.
        - In code:
            ```
            {
                "0": {
                    "Chroot name",
                    "url": "https://example.com/chroot.tar.gz",
                    ...
                },
                "1": {...
            }
            ```
    - «author» - your nickname, or just the nickname of the author of the chroot assembly. There are no restrictions, but it is not recommended to exceed 16 characters.
        - In code:
            ```
            {
                "0": {
                    "Chroot name",
                    "author": "Steve",
                    ...
                },
                "1": {...
            }
            ```
