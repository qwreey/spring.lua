
# spring.lua

spring module for lua env. working at everywhere such as roblox, luvit etc

# build in rojo

```sh
make build

or

rojo build default.project.json -o BuildResult.rbxmx
```

# use rojo submodule

```sh
cd <TO GITROOT>
git submodule add https://github.com/qwreey75/spring.lua spring
```

edit default.project.json (Or your own) Add
```json
"spring": {
    "$path": "spring"
}
```
