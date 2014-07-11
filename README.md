# Mercy Maternal Care

Custom software for a charity maternity clinic in the Philippines. This software is specifically designed for one particular clinic, though anyone can use parts or all of it freely as you see fit. See license for details. *Use at your own risk - there is no warranty.*

Currently the software concentrates upon the prenatal check ups during the pregnancy. Other phases of pregnancy handling are not yet implemented.

## Features

- New patient setup
  - Any number of patients allowed.
- Prenatal history
- Prenatal questionnaire
- Prenatal examinations
  - Lab results
  - Vaccinations
  - Prenatal measurements/notes
  - Referrals
  - Medicines administered
  - Health Teachings (to be completed)
- Search
  - exact and wildcard
  - search by priority number (scanning the priority badge/tag)
- Reports
  - 1 so far, more to come
  - Reports produce PDFs for storage, printing, etc.
  - Report input includes to and from dates, type of report, etc.
- Priority number scheduling
  - Barcode generation system to allow scanning priority badges/tags for
    faster processing
    - Generator script creates PDF of barcodes
    - Barcodes can then be permanently attached to priority badges/tags that the patients
      use when they arrive. This is done once to setup the priority
      badges/tags.
    - The queuing system uses priority badges/tags and scanners can be used to
      quickly access the patient's records as they proceed through the exam
      processes. (Note: staff should always confirm name of patient after
      scanning priority badge/tag.)
- User management (staff, etc.)
  - Roles
     - Supervisor
     - Attending
     - Clerk
     - Guard
     - Administrator
  - Permissions and ACL based upon roles
  - Any number of users/staff allowed.
- Web browser and mobile browser compatible
  - Native Android client in development (separate)
- Full logging of all changes to the database
  - All historical changes reviewable by supervisor role or admin role as
    appropriate
- HTTPS (HTTP redirects to HTTPS)
- Tests (132 to date)
- MIT license

## Status

Alpha - development is ongoing and nearing on-site pilot.

## Technology

- Nodejs - version v0.10.29 (or latest)
- MySQL

Web based and compatible with tablet browsers.

## Contributions

Contributions, comments, suggestions, issues and pull requests are welcome.

## License

The MIT License (MIT)

Copyright (c) 2014 Kurt Symanzik <kurt.symanzik@lightsys.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

