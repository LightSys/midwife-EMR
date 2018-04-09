# Midwife EMR

Midwife-EMR (Midwife Electronic Medical Record) is custom patient management
software for large charity maternity clinics in the Philippines serving the low
income community.

## Features at a glance

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
   - Health Teachings
   - Progress notes
- Labor and delivery
- Continued and immediate postpartum
- Discharge and Postpartum
- Birth Certificate printing
- Patient Search
   - exact and wildcard
   - search by priority number (scanning the priority badge/tag)
   - search by scheduled appointment day
   - search by date of birth
   - search by Phil Health ID or DOH ID
- Reports
   - To date these are reports required by the local government
      - Tetanus Reports 1 through 5
      - Iron Given Reports 1 through 5
      - Deworming Report
      - DOH Master list
      - Phil Health Daily Report
      - Inactives Report
      - Summary Report - everything about one patient in one report.
      - Vitamin A Report
      - Hep B Report
      - BCG Report
   - Reports produce PDFs for storage, printing, etc.
   - Report input includes to and from dates, type of report, etc.
- Priority number scheduling
   - Barcode generation system to allow scanning priority badges/tags for
    faster and efficient patient processing
      - Generator script creates PDF of barcodes
      - Barcodes can then be permanently attached to priority badges/tags that the patients
      use when they arrive. This is done once to setup the priority
      badges/tags.
      - The queuing system uses priority badges/tags and scanners can be used to
      quickly access the patient's records as they proceed through the exam
      processes.
      - Administration screen allows administrator to easily download barcode PDF to create badges, etc.
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
- Full logging of all changes to the database
   - All historical medical changes reviewable by supervisor role.
      - Allows supervisor to traverse forward and backword "through time"
        viewing the screens as they appeared across all pages of the application,
        or review only changes that occurred on a specific page.
      - Shows who made what changes at what time.
      - Is completely read-only, reviewing historical changes does not change
        data.
      - Fast - uses SPA technology so that reviewing changes are quick and
        simple.
- HTTPS (HTTP redirects to HTTPS)
- AGPLv3 license

## Some Additional Documentation

See the [wiki for more detailed user and system documentation](../../wiki).

**Note that the wiki is somewhat out of date in some respects.**

## The Setting

The clinic for which the application is designed and is being used performs
over 20,000 prenatal exams and delivers approximately 1600 babies each year.
In the Philippines, this type of maternity clinic is called a lay-in maternity
clinic.

Since the initial installation in 2015, other clinics in the Philippines have
also started using Midwife-EMR.

Our hope is that Midwife-EMR might be of use to many other lay-in
maternity clinics not only in the Philippines but elsewhere where
high-quality, free or low-cost, maternal services can be offered to those most
in need.

![ODroid XU4](docs/images/IMG_20161008_120458_rotated.jpg)

Due to the relatively frequent power outages at the current location of the
clinic, Midwife-EMR is currently running on an [ODroid
XU4](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G143452239825)
single board computer. This allows the wireless router and the server running
the Midwife-EMR application to stay operational for 5+ hours during a power
outage while running on a 600 watt UPS. The application itself is accessed
using tablets, some smartphones, laptops, and desktops. It is normal for 12 or
so users to be using the application, which is itself running on the ODroid
XU4, at any one time without any issues or any hint of performance
degradation.

A few facts about the specific XU4 setup that we are using.

- 64 GB eMMC card
- 64 GB class 10 SD card
- Built in ethernet port
- Optional wifi-module allowing broadcast of it's own wireless network

The SD card is solely used for automated backups.

## Technology Used

- Nodejs - version v6.x.x
- MySQL
- Nginx - reverse proxy for the application (optional)
- Socket.io
- Elm
- Docker (required for build environment for Elm code)
   - See npm scripts:
      - build_admin_client_compiler
      - admin_client_dev
      - admin_client_prod
      - build_medical_client_compiler
      - medical_client_dev
      - medical_client_prod

Web based and compatible with tablet browsers.

## Contributions

Contributions, comments, suggestions, issues and pull requests are welcome.

## License

Copyright (C) 2013-2018 LightSys Technology Services, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

See the file named AGPLv3.txt for license details.
