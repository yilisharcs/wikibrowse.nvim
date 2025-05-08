# Tasks

## debug

```nu
nu ./bin/wikibrowse.nu debug
```

## entr

```nu
fd . bin/ pandoc/ | entr -crs "nu ./bin/wikibrowse.nu debug"
```
