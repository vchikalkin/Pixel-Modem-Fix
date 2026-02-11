# Проверка на установку через Magisk
if $BOOTMODE; then
    ui_print "- Installing from Magisk app"
else
    ui_print "*********************************************************"
    ui_print "! Install from recovery is NOT supported"
    ui_print "! Please install from Magisk app"
    abort "*********************************************************"
fi

rm -f $MODPATH/system/vendor/firmware/carrierconfig/cfg.db || abort "Failed to delete old cfg.db!"
chmod +x $MODPATH/tools/sqlite3 || abort "Failed to change chmod to +x for sqlite3!"
cp -a /vendor/firmware/carrierconfig/cfg.db $MODPATH/system/vendor/firmware/carrierconfig/ || abort "Failed to copy cfg.db!"
SQL="
-- Обновляем 0 и 20001
UPDATE confmap
SET confman = (
    SELECT confman FROM confmap
    WHERE carrier_id = (
        SELECT carrier_id FROM confnames WHERE name='it_iliad'
    )
)
WHERE carrier_id IN ('0', '20001', '20005');

-- Добавляем 20005, если её нет
INSERT OR IGNORE INTO confmap (carrier_id, confman)
VALUES (
    '20005',
    (SELECT confman FROM confmap
     WHERE carrier_id = (
         SELECT carrier_id FROM confnames WHERE name='it_iliad'
     )
    )
);
"
$MODPATH/tools/sqlite3 $MODPATH/system/vendor/firmware/carrierconfig/cfg.db "$SQL" || abort "Failed to patch cfg.db!"
rm -f $MODPATH/tools/sqlite3 || abort "Failed to delete sqlite3!"

chcon u:object_r:vendor_fw_file:s0 $MODPATH/system/vendor/firmware/carrierconfig/cfg.db || ui_print "! Failed to set SELinux context."

