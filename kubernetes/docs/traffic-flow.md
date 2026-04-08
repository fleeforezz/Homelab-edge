## 🖥️Nginx (Global load balancer)

Run on:
+ Proxmox VM
+ Standalone Docker Vm
+ Not inside K8s

## 🔐 TLS Strategy

Nginx only does:
+ TCP LB
+ Health checks
+ Fail over

Traefik does:
+ HTTPS
+ Certs
+ Routing

## Nginx Config (TCP passthrough + health)

```nginx
stream {
    upstream k8s_clusters {
        least_conn;
        server 10.0.0.10:443 max_fails=3 fail_timeout=10s;
        server 10.0.0.11:443 max_fails=3 fail_timeout=10s;
    }

    server {
        listen 443;
        proxy_connect_timeout 5s;
        proxy_timeout 30s;
        proxy_pass k8s_clusters;
    }
}
```

What this give you
+ Detect dead clusters
+ Remove them automatically
+ No DNS changes
+ Fast failover

### Health-check endpoints (CRITICAL)
#### A. Pod-level health (K8s)

**Deployment readiness probe**
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 10
```

Pod removed from Service if unhealthy

#### B. Cluster-level health (Traefik)

Create a simple health endpoint

**Traefik static config**
```yaml
ping:
  entryPoint: web
```

Expose it:
```bash
http://cluster-ip:80/ping
```

#### C. Nginx checks Traefik, not pods

Nginx only cares:
> "Is Traefik alive ?"

Pods are Kubernetes problem

## 🌐Traefik inside each cluster (Traefik Ingress)

**Traefik Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik
spec:
  type: LoadBalancer
  ports:
    - port: 443
      targetPort: 443
```

Each cluster gets its own IP:

```nginx
Cluster A → 10.0.0.10
Cluster B → 10.0.0.11
```

**Homepage IngressRoute**
```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: homepage
spec:
  entryPoints:
    - websecure
  routes:
  - match: Host(`home.lab.local`)
    kind: Rule
    services:
      - name: homepage
        port: 3000
```

## 🔁 Zero-downtime upgrades (This is important)
### A. Pod rolling updates

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

+ New pod starts
+ Old pod stays
+ Traffic never drops

### B. Cluster upgrades (one cluster at a time)

```css
1. Drain Cluster A
2. NGINX sends traffic to B
3. Upgrade A
4. Bring A back
5. Repeat for B
```

Nginx handles traffic shift automatically

### C. Traefik reloads are seamless

Traefik:
+ Watches CRDs
+ Reloads config live
+ No connection drops

## ⚠️ Failure scenarios (Real Life)

| Failure      | Result                |
| ------------ | --------------------- |
| Pod dies     | K8s removes pod       |
| Service dies | Traefik retries       |
| Traefik dies | NGINX removes cluster |
| Cluster dies | Traefik rerouted      |
| NGINX dies   | (needs HA)            |

## 🧱 NGINX HA (Recommended)

```css
[ Keepalived / VRRP ]
        |
   Virtual IP
        |
      NGINX
```

Or:
+ Two NGINX nodes
+ DNS round-robin

