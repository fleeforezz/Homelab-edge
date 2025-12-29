# Architecture
```shell
                    Internet
                        |
                ┌────────────────┐
                │     NGINX      │   ← Global L7/L4 LB (VM)
                └───────┬────────┘
                        |
         ┌──────────────┼──────────────┐
         │              │              │
   ┌───────────┐   ┌───────────┐   ┌───────────┐
   │ Cluster A │   │ Cluster B │   │ Cluster C │
   │  Traefik  │   │  Traefik  │   │  Traefik  │
   └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
         │               │               │
    Services          Services         Services
         │               │               │
        Pods            Pods            Pods
```
