git reset HEAD~1
git add .gitignore
git add fixngo/apps/technician_app/lib/
git add fixngo/apps/customer_app/lib/
git add fixngo/apps/admin_panel/src/
git add fixngo/backend/src/
git add fixngo/backend/package.json
git add fixngo/backend/package-lock.json
git commit -m "fix: resolve technician app dispatch broadcast, add Rapido-style job allocation, and configure MQTT websockets"
git push
