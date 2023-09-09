lang = "pt"
src = open("ia_"+lang+".po", 'r')
skippables = []

for line in src:
    if line.find("#. STRINGS.") != -1:
        skippables.append(line)

src.close()

out = open("appendable_"+lang+".po", 'w')
new = open("mobile_"+lang+".po", 'r')
shouldwrite = False

for line in new:
    if not shouldwrite and line.find("#. STRINGS.") != -1:
        if line not in skippables:
            shouldwrite = True
    if shouldwrite == True:
        if len(line) < 4:
            shouldwrite = False
        #src.write(unicode(line,"utf-8").encode("iso-8859-1"))
        out.write(line)

out.close()
new.close()
