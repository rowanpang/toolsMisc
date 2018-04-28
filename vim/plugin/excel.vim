command! -nargs=0 Excel call ParseExcel()

if !has("pythonx")
    echo "excel.vim requires support for python"
    finish
endif

"au BufRead,BufNewFile *.xls,*.xlam,*.xla,*.xlsb,*.xlsx,*.xlsm,*.xltx,*.xltm,*.xlt :call ParseExcel()


function! ParseExcel()
set nowrap
pythonx << EOF
import vim
import openpyxl
from openpyxl import load_workbook
import xlrd

openedtab = 0
# for non-English characters
def getRealLengh(str):
    length = len(str)
    for s in str:
        if ord(s) > 256:
            length += 1
    return length

# get current file name
vim.command("let currfile = expand('%:p')")
currfile = vim.eval("currfile")

if currfile.lower().strip().endswith('.xls'):
    excelobj = xlrd.open_workbook(currfile)
    for sheet in excelobj.sheet_names():
        shn = excelobj.sheet_by_name(sheet)
        try: sheet = sheet.replace(" ", "\\ ")
        except: pass
        rowsnum = shn.nrows
        if not rowsnum:
            continue
        cmd = "tabedit %s" % (sheet)
        vim.command(cmd)
        for n in range(rowsnum):
            line = ""
            for val in shn.row_values(n):
                try: val = val.replace('\n',' ')
                except: pass
                #val = isinstance(val,  basestring) and val.strip() or str(val).strip()
                line += str(val) + ' ' * (30 - getRealLengh(str(val)))
            vim.current.buffer.append(line)

    for i in range(excelobj.nsheets):
        vim.command("tabp")
    vim.command("q!")

else:
    wb = load_workbook(currfile)
    for name in wb.sheetnames:
        ws = wb.get_sheet_by_name(name)

        try: sName = name.replace(" ", "\\ ")
        except: pass

        cmd = "tabedit %s" % (sName)
        vim.command(cmd)
        openedtab += 1

        for rvs in ws.values:
            line=''
            for val in rvs:
                if not val:
                    line += ' ' * 30
                    continue
                try: val = val.replace('\n',' ')
                except: pass

                #val = isinstanae(val,  basestring) and val.strip() or str(val).strip()
                line += str(val) + ' ' * (30 - getRealLengh(str(val)))

            vim.current.buffer.append(line)

    for i in range(openedtab):
        vim.command("tabp")            #jump to the first tab
    vim.command("q!")                    #close it
EOF

endfunction
