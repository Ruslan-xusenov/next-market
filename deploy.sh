#!/bin/bash

# Matn ranglari (Kodni oson o'qish uchun)
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🚀 Yangilanish boshlanmoqda...${NC}"

# 1. Loyiha papkasiga o'tish (O'zingizning serverdagi to'g'ri manzilni yozasiz, masalan /var/www/next-market)
CD_DIR="/var/www/next-market"
echo -e "${GREEN}📁 Loyiha papkasiga o'tilmoqda: $CD_DIR${NC}"
cd $CD_DIR || { echo "Loyiha papkasi topilmadi!"; exit 1; }

# 2. GitHub'dan eng so'nggi kodni olib kelish
echo -e "${GREEN}⬇️ GitHub dan oxirgi o'zgarishlar yuklab olinmoqda...${NC}"
git pull origin main

# 3. Virtual muhitni yoqish va kutubxonalarni o'rnatish
echo -e "${GREEN}📦 Kutubxonalar sinxronizatsiya qilinmoqda...${NC}"
source venv_linux/bin/activate
pip install -r requirements.txt

# 4. Ma'lumotlar bazasini yangilash
echo -e "${GREEN}💽 Ma'lumotlar bazasi migratsiyalari o'tkazilmoqda...${NC}"
python manage.py migrate

# 5. Statik fayllarni yig'ish (CSS/JS ni yangilash)
echo -e "${GREEN}🎨 Statik fayllar yangilanmoqda...${NC}"
python manage.py collectstatic --noinput

# 6. Web-server qayta ishga tushirilmoqda
echo -e "${GREEN}🔄 Django web-serveri (Daphne) qayta ishga tushirilmoqda...${NC}"
sudo systemctl restart nextmarket

echo -e "${GREEN}✅ Muvaffaqiyatli yakunlandi! Saytingiz to'liq yangilandi. 🎉${NC}"
