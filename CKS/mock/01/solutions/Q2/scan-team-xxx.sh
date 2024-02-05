trivy image --scanners vuln --output r1.txt --severity CRITICAL nginx:1.19-alpine-perl
trivy image --scanners vuln --output r2.txt --severity CRITICAL nginx:1.23-bullseye-perl
trivy image --scanners vuln --output r3.txt --severity CRITICAL mariadb:10.8-focal
trivy image --scanners vuln --output r4.txt --severity CRITICAL docker.io/library/mysql:8.0.33
