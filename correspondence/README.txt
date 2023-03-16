1. Example cover letter (copy and modify):

2020-06-20cover-letter-epj-data-science.*

Edit:
2020-06-20cover-letter-epj-data-science.body.ex

Build:
pdflatex 2020-06-20cover-letter-epj-data-science

2. Example response to reviewers with
   well structured formatting and numbering for comments
   (copy and modify):

2022-05-31epj-data-science-response.*

Edit:
2022-05-31epj-data-science-response.body.tex

Build:
pdflatex 2022-05-31epj-data-science-response

As needed, break down comments from reviewers into reasonable elements.

Notes:

YYYY-MM-DD prefix for organization.
YYYY-MM-DD-cover-letter-journal.*
YYYY-MM-DD-response-journal.*

Rename files with meaningful names.

% ./bin/rename 2022-05-31epj-data-science-response YYYY-MM-DDnext-journal-to-reject-our-magnicent-manuscript 2022-05-31epj-data-science-response.*


Use of currfile package allows wrapper file 
(e.g., 2022-05-31epj-data-science-response.tex
calls *.settings.tex and *.body.tex)

