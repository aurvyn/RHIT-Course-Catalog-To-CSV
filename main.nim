import httpclient, json, strutils, sequtils, sugar, re

const
    COURSES = ["ID", "Name", "Description", "Subject", "Grad Studies Eligible", "Credit Hours", "Term Available", "Prerequisites", "Corequisites"]
    DELIMITER = "\t"
let
    client = newHttpClient()
    catalog = parseJson(client.getContent("https://www.rose-hulman.edu/academics/course-catalog/current/index.json"))
    file = open("courses.csv", fmWrite)
    linkHead = re"<a.*\"">"
    betweenOr = re"</a>\s*or\s*<a.*\"">"
    betweenAnd = re"</a>[,\s]*and[either\s]*<a.*\"">"
    extraSpace = re"\s+"
file.write(COURSES.join(DELIMITER))
for course in catalog["courses"]:
    var 
        index = 0
        page = client.getContent("https://www.rose-hulman.edu/academics/course-catalog/current/" & course["link"].getStr().replace(" ", "%20"))
        content : string
    file.write('\n' & ["num", "name", "description", "subject", "gradStudiesEligible"].map(section => course[section].getStr().strip()).join(DELIMITER))
    for section in COURSES[5..8]:
        index = page.find(section, index)
        content = page[index+len(section)+1..page.find("</li>", index+12)-1]
        if section in COURSES[7..8]:
            content = content.multiReplace([(linkHead, " "), (betweenOr, "/"), (betweenAnd, " + ")]).replace("</a>", " ").replace(extraSpace, " ")
        file.write(DELIMITER & content.strip())
client.close()
file.close()
