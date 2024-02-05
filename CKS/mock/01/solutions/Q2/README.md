# Solution

List the images in team-xxx namespace:

    kubectl -n team-xxx get pods -o yaml | grep image:

Dedup then create trivy scan command as:

    trivy image --skip-java-db-update --scanners vuln --output r1.txt --severity CRITICAL nginx:1.19-alpine-perl
    trivy image --skip-java-db-update --scanners vuln --output r2.txt --severity CRITICAL nginx:1.23-bullseye-perl
    trivy image --skip-java-db-update --scanners vuln --output r3.txt --severity CRITICAL mariadb:10.8-focal
    trivy image --skip-java-db-update --scanners vuln --output r4.txt --severity CRITICAL docker.io/library/mysql:8.0.33

Without the `--skip-java-db-update` and `--scanners vuln`, trivy takes a lot of
time to download java db and scan non-vulnerability issue such as secret.

nginx:1.19-alpine-perl (belongs to deployment1) has 9 CRITICAL issues.
nginx:1.23-bullseye-perl (belongs to deployment4) has 6 CRITICAL issues.
mariadb:10.8-focal has no CRITICAL issue.
mysql:8.0.33 has no CRITICAL issue.

Create scale down command:

    kubectl -n team-xxx scale deployment deployment1 deployment4 --replicas=0
