-- Liquid Trucking Operations Center: load the starting Driver FAQs (115 FAQs).
-- Run ONCE in Supabase after 08-faq.sql: SQL Editor -> New query -> paste all of this -> Run.
-- Safe to run again: FAQs that already exist are skipped, so nothing is duplicated or overwritten.
-- Built from: Payroll FAQ, Regional Driver Pay Plan (v1.2.0), 2026-2027 Benefits Guide, Liquid Trucking FAQ Sheet (10/22/26),
-- with Jason's answers from Nov 4, 2026. Each FAQ's history starts with an "Imported" entry.

insert into public.faq_categories (name, sort) values
  ('Hiring and the job', 10),
  ('Pay and paychecks', 20),
  ('Paysheets and Paycor', 30),
  ('PTO and bonuses', 40),
  ('Pay plan details', 50),
  ('401(k) retirement', 60),
  ('Enrolling and eligibility', 70),
  ('Medical and prescriptions', 80),
  ('Everyday care, dental and vision', 90),
  ('Life, disability and supplemental insurance', 100),
  ('Extra support and perks', 110),
  ('Contacts and full documents', 120),
  ('For recruiters', 130)
on conflict (name) do nothing;

insert into public.faq (id, category, question, answer, links, sort, created_by_name, updated_by_name) values
  (87, 'Hiring and the job', 'What are the basic qualifications?',
   '- Class A CDL with 12 months of Class A experience, hauling any kind of freight
- 23 or older
- Pass a background check, drug screen and physical
- No major moving violations in the last 3 years
- No felonies in the last 5 years

No tanker experience is needed, but you need the tanker endorsement (FAQ 88).

*Source: FAQ Sheet p. 1*',
   '[{"label": "Apply online", "url": "https://intelliapp.driverapponline.com/c/liquidtrucking?r=liquidtruckinghomepage&uri_b=ia_Bulldog_1057826933"}]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (88, 'Hiring and the job', 'Do I need tanker and Hazmat endorsements?',
   '- **Tanker:** you don''t need it to apply, but it has to be on your paper license before orientation. Get your fingerprints done before you add the endorsement. Doing them after can hold things up by about 2 months.
- **Hazmat:** required for every driver. In most of the hiring area you can get it while you''re training or working, and we help with the process and pay you back for fingerprints. Drivers in Denver must already have it. Drivers in Chicago are strongly encouraged to have it, because without it, scheduling around that area''s freight is harder.

See also FAQ 73.

*Source: FAQ Sheet p. 1*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (89, 'Hiring and the job', 'Are there work history requirements?',
   'We generally pass on candidates who''ve had more than 3 jobs in the past 12 months. We''re also looking for drivers who have worked within the past 12 months.

*Source: FAQ Sheet p. 1*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (90, 'Hiring and the job', 'Do you hire drivers in a SAP (return-to-duty) program?',
   'Case by case. Have them send in an application.

*Source: FAQ Sheet p. 2*',
   '[]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (91, 'Hiring and the job', 'Do you have owner-operator or team positions?',
   'No. We''re a fleet of company drivers only, and we don''t hire teams right now.

*Source: FAQ Sheet p. 1*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (92, 'Hiring and the job', 'Where are the terminals?',
   'There are two: Plattsmouth, Nebraska, just south of Omaha, and South Sioux City, Nebraska, on the southern edge of Sioux City, Iowa.

*Source: FAQ Sheet p. 1*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (93, 'Hiring and the job', 'How do I apply, or who do I call?',
   'Apply online, or call recruiting at 402-298-7043.

*Source: FAQ Sheet p. 1, p. 6*',
   '[{"label": "Apply online", "url": "https://intelliapp.driverapponline.com/c/liquidtrucking?r=liquidtruckinghomepage&uri_b=ia_Bulldog_1057826933"}]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (94, 'Hiring and the job', 'What happens during orientation and training?',
   'Orientation and training take two weeks together. If you live in the Omaha area, you go home each night and work at the terminal each day. If you''re from out of town, we provide transportation and your own room at a local hotel, such as the Inn and Suites in Papillion. You learn our tanker operations step by step and meet the office and shop staff. For training pay, see FAQ 5.

*Source: FAQ Sheet p. 2*',
   '[{"label": "Orientation info page", "url": "https://lp.constantcontactpages.com/cu/YWwaZRK/orientationpage"}]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (95, 'Hiring and the job', 'Is this local, regional or OTR? Can I pick where I run?',
   'It''s OTR. We run all 48 states, focused on the central U.S., with the most freight in Nebraska, Iowa, Kansas, South Dakota and Missouri. We don''t have local jobs. You need to be able to run anywhere in our general operating area at any time.

*Source: FAQ Sheet p. 2, p. 5*',
   '[]'::jsonb, 90, 'Jason Eisenman', 'Jason Eisenman'),
  (96, 'Hiring and the job', 'What does a typical week look like?',
   'Drivers who are home every week choose one of two home-time plans:

- Leave on **Sunday** and get home on **Friday**, or
- Leave on **Monday** and get home on **Saturday**.

To be honest up front: there''s no promised time to leave or get home on those days. You could leave or get home at any time that day. Trucking is full of hurdles and delays, and even the best-planned load can run late.

You take a 10-hour reset each night and a 34-hour reset each weekend, on a 70-hour clock. Some weekends are longer at home; others are just the 34-hour reset. OTR drivers average 2-5 loads a week, and an average load is about 250-515 miles. Pay is hourly, not by the mile, so there''s no need to chase miles: driving, loading, unloading, washouts and even waiting in line are all paid.

*Source: FAQ Sheet p. 2, p. 4, home-time plans confirmed by Jason Nov 4, 2026*',
   '[]'::jsonb, 100, 'Jason Eisenman', 'Jason Eisenman'),
  (97, 'Hiring and the job', 'How much can I make?',
   'Base drive-time pay is $30 an hour. First-year drivers average $1,700-$2,400 gross a week after training, or about $90,000-$110,000 in the first year.

*Source: FAQ Sheet p. 2*',
   '[]'::jsonb, 110, 'Jason Eisenman', 'Jason Eisenman'),
  (98, 'Hiring and the job', 'Do you pay overtime?',
   'No, but you earn $1.50 of PTO for every hour of drive time recorded on your ELD (FAQs 17-21). It typically adds up to $3,200-$3,700 a year, and you can use it however you want. There''s no limit on how much you can save. Some drivers cash it out, and others bank it like a savings account.

*Source: FAQ Sheet p. 2*',
   '[]'::jsonb, 120, 'Jason Eisenman', 'Jason Eisenman'),
  (99, 'Hiring and the job', 'Do you have an idle policy?',
   'Idle only when the situation requires it, because fuel is expensive. You manage it yourself, and drivers who keep idling low earn an idle bonus of up to $2,600 a year (FAQ 79).

*Source: FAQ Sheet p. 2*',
   '[]'::jsonb, 130, 'Jason Eisenman', 'Jason Eisenman'),
  (100, 'Hiring and the job', 'Can I bring my pet?',
   'No. Because we haul food-grade and Kosher products, pets can''t ride along. If you have a service animal, we''ll review the request through the ADA interactive process.

*Source: FAQ Sheet p. 3, p. 7*',
   '[]'::jsonb, 140, 'Jason Eisenman', 'Jason Eisenman'),
  (101, 'Hiring and the job', 'Can I bring a rider or passenger?',
   'Yes, if they''re over 10, after you finish your first 90 days (probation).

*Source: FAQ Sheet p. 3*',
   '[]'::jsonb, 150, 'Jason Eisenman', 'Jason Eisenman'),
  (102, 'Hiring and the job', 'Do I have to load and unload the truck?',
   'You''re responsible for watching loading and unloading, and most of the time for the setup too. Many customers load or unload for you, but you''re still responsible for making sure it''s done safely.

*Source: FAQ Sheet p. 3*',
   '[]'::jsonb, 160, 'Jason Eisenman', 'Jason Eisenman'),
  (103, 'Hiring and the job', 'What trucks do you run?',
   'Mostly Freightliners, with some Volvos, and mostly automatics. We replace our 25 oldest trucks with new ones every year; the oldest truck in service right now is a 2016 Glider. Most trucks have an APU or another system for idling. Trucks are governed at 65 mph on the pedal and 70 on cruise. If you have a fridge, inverter, CB radio or microwave, our shop installs them during training.

*Source: FAQ Sheet p. 3*',
   '[]'::jsonb, 170, 'Jason Eisenman', 'Jason Eisenman'),
  (104, 'Hiring and the job', 'Do the trucks have cameras that face the driver?',
   'Our newer trucks have dash cams that face out over the hood. The newest cameras also have a driver-facing side, but it isn''t turned on, and we''ve put custom caps over it for privacy.

*Source: FAQ Sheet p. 3*',
   '[]'::jsonb, 180, 'Jason Eisenman', 'Jason Eisenman'),
  (105, 'Hiring and the job', 'Will I have my own truck?',
   'Yes. We don''t slip seat. The only time you''d switch is if your truck breaks down: we give you a spare to keep you moving, and move you back once yours is fixed.

*Source: FAQ Sheet p. 3*',
   '[]'::jsonb, 190, 'Jason Eisenman', 'Jason Eisenman'),
  (106, 'Hiring and the job', 'What do we haul?',
   'Mostly agricultural products, plus food-grade and hazmat loads. We don''t haul gasoline or dairy.

*Source: FAQ Sheet p. 2, p. 3*',
   '[]'::jsonb, 200, 'Jason Eisenman', 'Jason Eisenman'),
  (107, 'Hiring and the job', 'How long does loading, unloading or a tank wash take?',
   'Usually 1-2 hours each. You don''t do washouts yourself: you pull into the wash facility, and they handle it.

*Source: FAQ Sheet p. 4*',
   '[]'::jsonb, 210, 'Jason Eisenman', 'Jason Eisenman'),
  (108, 'Hiring and the job', 'Is dispatch forced?',
   'Yes. Drivers are expected to complete every load they''re assigned. We work hard to help with family emergencies and planned time off.

*Source: FAQ Sheet p. 4*',
   '[]'::jsonb, 220, 'Jason Eisenman', 'Jason Eisenman'),
  (109, 'Hiring and the job', 'What ELD and communication system do the trucks use?',
   'Isaac Systems, in every tractor.

*Source: FAQ Sheet p. 4*',
   '[]'::jsonb, 230, 'Jason Eisenman', 'Jason Eisenman'),
  (110, 'Hiring and the job', 'Can I take the truck home on my time off?',
   'Yes, as long as there''s a safe place at or near your home to park a loaded truck and trailer.

*Source: FAQ Sheet p. 4*',
   '[]'::jsonb, 240, 'Jason Eisenman', 'Jason Eisenman'),
  (111, 'Hiring and the job', 'What''s your driver turnover?',
   'It runs 20-35% a year. Most of it is drivers who want to be home every night, since we don''t have local jobs. More than half of our drivers have been with us 5-29 years.

*Source: FAQ Sheet p. 5*',
   '[]'::jsonb, 250, 'Jason Eisenman', 'Jason Eisenman'),
  (112, 'Hiring and the job', 'How many drivers does each dispatcher handle?',
   'About 35 on average.

*Source: FAQ Sheet p. 5*',
   '[]'::jsonb, 260, 'Jason Eisenman', 'Jason Eisenman'),
  (113, 'Hiring and the job', 'How often will I be home?',
   'It depends on where you live. The Hiring Map colors each county by home time:

- **Green:** about 1 week out
- **Yellow:** 1-2 weeks (St. Louis runs 2)
- **Orange:** 2-3 weeks
- **Red:** 3+ weeks

These colors are a guideline. Unless a driver lives firmly inside a green county, double-check with Planners before promising home time. The map also shows where we''re not hiring right now.

*Source: Hiring Map*',
   '[{"label": "Hiring Map", "url": "https://www.liquidtrucking.io/recruiting/hiring-map"}]'::jsonb, 270, 'Jason Eisenman', 'Jason Eisenman'),
  (114, 'Hiring and the job', 'Is there a Liquid Trucking podcast?',
   'Yes.

*Source: FAQ Sheet p. 6*',
   '[{"label": "Liquid Trucking podcast", "url": "https://podcast.liquidtrucking.com/playlists"}]'::jsonb, 280, 'Jason Eisenman', 'Jason Eisenman'),
  (1, 'Pay and paychecks', 'When is the payroll week, and when do I get paid?',
   'The payroll week runs Monday through Sunday. Your paystub shows up in Paycor on Wednesday evening, and direct deposit lands on Friday. Holidays can move the pay date or the Wednesday paystub. The Daily Safety Message the week before lists any holiday changes.

*Source: Payroll FAQ p. 1*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (2, 'Pay and paychecks', 'Why can I see my check on Wednesday but not the money?',
   'Paycor releases the paystub early so you can look it over. Direct deposit is still scheduled for Friday. The time the money actually shows up depends on your bank.

*Source: Payroll FAQ p. 1*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (3, 'Pay and paychecks', 'What is my driving pay made of?',
   'Drive-time pay is made up of a guaranteed base wage, per diem, and Hazmat, safety and fuel bonuses. After your first full quarter, production and idle-time bonuses can be added, and years-of-service pay is added as you reach milestones. On your check, per diem shows on its own Per Diem line, and the rest is added together on the Driving line. The current rates are in the attached Regional Driver Pay Plan.

*Source: Pay Plan p. 1, Payroll FAQ p. 1, p. 3*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (4, 'Pay and paychecks', 'How does per diem show on my check?',
   'The Per Diem line shows a total dollar amount in the Current section, not hours. To check it, multiply your driving hours by the per diem rate in the Pay Plan.

*Source: Payroll FAQ p. 1, p. 3*',
   '[]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (5, 'Pay and paychecks', 'How is orientation and training paid?',
   'Every new driver is paid the same way during the two training weeks:

- **$1,500 per week** for a full Monday-Friday week. This covers all work that week, including work after you''re released from training and driving the truck home.
- **$300 per day** if you don''t work the full week. A day you don''t work, including a holiday you have off, takes $300 (gross) off that week''s training pay.
- **$1,000 transition bonus** on your first Friday.

That''s $4,000 total for a full two weeks of training.

*Source: Payroll FAQ p. 1, Pay Plan p. 2, confirmed by Jason Nov 4, 2026*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (6, 'Pay and paychecks', 'What do the lines on my paystub mean?',
   '| Line on your check | What it is |
| --- | --- |
| Driving | Taxable drive-time pay: base wage plus Hazmat, safety and fuel bonuses, and any quarterly and years-of-service additions. |
| STP Hourly | Hourly pay for qualifying loading, unloading and washout time (FAQ 75). |
| Stop Flat | A flat payment for each listed activity, such as drops, hooks and trailer changes (FAQ 75). |
| Per Diem | Per diem for each driving hour, shown as a dollar total, not hours. |
| Layover | Hourly pay for qualifying wait time after the first two hours (FAQ 7). |
| NonDFG | Drive for Gold cash-outs within your first $400 of the calendar year (not taxed). |
| Tax DFG | Drive for Gold cash-outs above $400 for the year (taxed). |
| 34 HSP | Payment for each qualifying 34-hour break taken on the road (FAQ 8). |

*Source: Payroll FAQ p. 3*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (7, 'Pay and paychecks', 'How is layover paid?',
   'Layover is paid by the hour once you''ve had two hours of qualifying wait time, starting with the third hour. It''s meant for breakdowns, repair delays and similar events. It doesn''t apply when you''re at home for any reason, when you''re stopped for weather, or for loading, unloading and washout time, which is already paid hourly. Request it on an Additional Paysheet. The rate is in the Pay Plan.

*Source: Pay Plan p. 2, Payroll FAQ p. 2, p. 3*',
   '[]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (8, 'Pay and paychecks', 'What is 34-hour reset pay?',
   'You get a set payment for each qualifying 34-hour break taken on the road, away from home, while on a load. It doesn''t count if you asked to take the reset at a particular place, even if that place is away from home. Submit it on an Additional Paysheet. The amount is in the Pay Plan.

*Source: Pay Plan p. 1, p. 2, Payroll FAQ p. 2, p. 3*',
   '[]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (9, 'Pay and paychecks', 'What is a Driver Settlement Sheet?',
   'It''s an email you get on Wednesday evenings that breaks down all of your loads from the week before. Each load shows its STP Hourly hours and any Stop Flat payments. Use it to compare load-by-load detail against your paycheck.

*Source: Payroll FAQ p. 3*',
   '[]'::jsonb, 90, 'Jason Eisenman', 'Jason Eisenman'),
  (10, 'Pay and paychecks', 'I have a question about my check. What should I do?',
   'First, look over your paystub and your paysheet. If you still have a question, contact Payroll. Include the pay date, the day or activity, the hours, and the earning type you''re asking about.

*Source: Payroll FAQ p. 2*',
   '[]'::jsonb, 100, 'Jason Eisenman', 'Jason Eisenman'),
  (11, 'Paysheets and Paycor', 'When are Additional Paysheets due?',
   'Additional Paysheets are due Monday by 11:59 PM. After midnight you can no longer pick the prior week. If you miss it, submit it with the next week''s week-ending date, and it will be paid on the next week''s check.

*Source: Payroll FAQ p. 2*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (12, 'Paysheets and Paycor', 'What goes on an Additional Paysheet?',
   'Reimbursements, layover pay, PTO cash-outs and 34-hour breaks. Every Additional Paysheet is submitted in DeliveRecon.

*Source: Payroll FAQ p. 2*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (13, 'Paysheets and Paycor', 'How do I view my actual paystub?',
   '1. In Paycor, go to **Pay & Taxes**.
2. Click the pay date you want to see.
3. Click **PDF** in the top-right corner.

*Source: Payroll FAQ p. 2*',
   '[{"label": "Paycor", "url": "https://www.paycor.com"}]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (14, 'Paysheets and Paycor', 'How do I change my tax withholding?',
   '1. In Paycor, go to **Pay & Taxes**.
2. Select **Taxes**.
3. Choose the withholding you want to change.
4. Click the three dots in the top-right and select **Update Withholding**.

Payroll can walk you through it if you need help.

*Source: Payroll FAQ p. 2*',
   '[{"label": "Paycor", "url": "https://www.paycor.com"}]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (15, 'Paysheets and Paycor', 'How do I update my address, phone number or other profile information?',
   '1. Open Paycor.
2. Click your picture in the top-left to go to your profile.
3. Select **Edit Personal Information** or **Edit Contact Information**.

Payroll can help if needed.

*Source: Payroll FAQ p. 2*',
   '[{"label": "Paycor", "url": "https://www.paycor.com"}]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (16, 'Paysheets and Paycor', 'How do I add, change or turn off a direct deposit account?',
   '1. In Paycor, go to **Pay & Taxes**.
2. Select **Direct Deposit**.
3. To edit or turn off an account, click it, then the three dots in the top-right.
4. To add an account, click the **+** in the top-right of Direct Deposit.

**Expect a call from Payroll after any direct deposit change.** They call to confirm it was really you.

*Source: Payroll FAQ p. 2*',
   '[{"label": "Paycor", "url": "https://www.paycor.com"}]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (17, 'PTO and bonuses', 'How do I earn PTO?',
   'PTO builds up automatically for every hour you drive, and it''s added to your PTO bank weekly, after each full workweek. Paycor does the math for you. The rate is in the Pay Plan.

*Source: Payroll FAQ p. 1, Pay Plan p. 4*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (18, 'PTO and bonuses', 'Why does my PTO show as hours instead of dollars?',
   'Paycor labels it as hours, but the number is really the dollar amount you can cash out. For example, 425.00 hours means $425.00 is available.

*Source: Payroll FAQ p. 1*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (19, 'PTO and bonuses', 'How do I cash out PTO?',
   'In DeliveRecon, submit a Driver Additional Paysheet and enter the dollar amount under Paid Time Off. It''s due Monday by 11:59 PM like any Additional Paysheet.

*Source: Payroll FAQ p. 1, p. 2*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (20, 'PTO and bonuses', 'How do I request time off? Do I have to use PTO for it?',
   'Request time off through your ELD and get your manager''s approval. Taking time off and cashing out PTO are separate. You don''t have to cash out PTO to take time off, and you can cash it out whenever you choose. Never request time off through Paycor.

*Source: Payroll FAQ p. 1*',
   '[]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (21, 'PTO and bonuses', 'Does my PTO carry over to next year?',
   'Yes. PTO carries over from year to year, and there''s no cap.

*Source: Payroll FAQ p. 1*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (22, 'PTO and bonuses', 'How are Drive for Gold cash-outs taxed?',
   'The first $400 you cash out each calendar year is not taxed (NON DFG on your check). Anything after $400 is taxed (TAX DFG).

Example with $250 cash-outs:

- 1st cash-out: $250 NON DFG
- 2nd cash-out: $150 NON DFG + $100 TAX DFG
- Every cash-out after that: TAX DFG

*Source: Payroll FAQ p. 1, p. 3*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (23, 'PTO and bonuses', 'How do the quarterly performance bonuses work?',
   'They start after your first full quarter. Your production ranking (FAQ 78) and idle time (FAQ 79) can each add to your driving rate for the next quarter. They aren''t paid as a lump sum: Q1 results set your Q2 rate, Q2 sets Q3, Q3 sets Q4, and Q4 sets Q1 of the next year. You have to still be employed when the next quarter starts.

*Source: Payroll FAQ p. 4, Pay Plan p. 3*',
   '[]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (24, 'PTO and bonuses', 'Do I earn more the longer I''m here?',
   'Yes. A years-of-service amount is added to every driving hour, on top of your rate. It goes up for each year you complete, through 25 years. The schedule is in the Pay Plan.

*Source: Pay Plan p. 1, p. 4, Payroll FAQ p. 4*',
   '[]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (25, 'PTO and bonuses', 'Where can I find the full pay rules?',
   'The Regional Driver Pay Plan is attached to this FAQ. The version here is 1.2.0, last revised September 18, 2026. It has every pay rule, activity code and bonus table.

*Source: Pay Plan p. 1*',
   '[]'::jsonb, 90, 'Jason Eisenman', 'Jason Eisenman'),
  (72, 'Pay plan details', 'What pay is guaranteed?',
   'A base drive-time wage is guaranteed for every driving hour, no matter what. Per diem is part of that base, not added on top. It''s non-taxable when you meet the company''s per diem rules. Hazmat, safety, fuel, production, idle-time and years-of-service pay are separate, and each has its own rules.

*Source: Pay Plan p. 1, p. 3*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (73, 'Pay plan details', 'Do I need a Hazmat endorsement?',
   'Yes. A current Hazmat endorsement is required for the job, and it adds a Hazmat bonus to every driving hour. New hires who don''t have it yet get 60 days to get it, and they keep the bonus during that time. If you don''t have it after 60 days, the bonus stops until you get it, then starts again right away. If your endorsement expires, you lose the bonus until you renew it.

*Source: Pay Plan p. 1, p. 3*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (74, 'Pay plan details', 'How does the safety bonus work?',
   'You start with a safety bonus on every driving hour. Safety reviews it every quarter. To keep it:

- Stay accident-free and avoid traffic tickets.
- Use your ELD correctly, keep log violations under 10%, and send information in real time.
- Finish your quarterly safety training on time, and meet with Safety each quarter.
- Do full pre-trip and post-trip inspections, and check the tank inside before and after each trip. If product is left, contact Dispatch and send a photo.
- Watch loading and unloading closely, and respond right away to spills.
- Follow dispatch and customer instructions, and communicate so pickups and deliveries are on time.
- Look and act professional with customers.
- Carry and take care of the required equipment, tools and PPE.
- Give Dispatch at least one week''s notice for planned time off.
- Turn in paperwork on time, and tell Dispatch about demurrage after 2 hours at a shipper or customer.

*Source: Pay Plan p. 4, p. 5*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (75, 'Pay plan details', 'How are loading, unloading, washouts and trailer moves paid?',
   'Loading, unloading and washout time is paid by the hour, plus a flat payment for the activity. Your ELD arrival and departure messages start and stop the clock. You have to be at an approved location, doing a listed activity.

| Code | Activity | Paid |
| --- | --- | --- |
| LLD | Live load | Hourly + flat |
| LUL | Live unload | Hourly + flat |
| WSH | Trailer wash | Hourly + flat |
| CTR | Change trailer | Flat |
| DLT | Drop loaded trailer | Flat |
| DMT | Drop empty trailer | Flat |
| DRL | Final drop loaded trailer | Flat |
| DTW | Drop trailer for wash | Flat |
| HLT | Hook loaded trailer | Flat |
| HMT | Hook empty trailer | Flat |
| HPL | Hook preloaded trailer | Flat |

On your check, the hourly pay shows as STP Hourly and the flat payments show as Stop Flat.

*Source: Pay Plan p. 2, Payroll FAQ p. 3*',
   '[]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (76, 'Pay plan details', 'What can reduce my safety bonus?',
   'Every event is reviewed first. An accident only counts if it was preventable, and a complaint only counts if it''s confirmed. Reductions usually start the next quarter, and they never touch your guaranteed base pay. For preventable accidents, the reduction depends on what the event cost the company. Other events that can reduce it:

- Speeding or other traffic tickets
- Confirmed customer complaints, or breaking a customer''s site rules
- Not wearing required PPE
- Road rage complaints
- Log violations over 10%, or changing drive time on purpose
- Skipped pre-trip inspections, dirty equipment, or late pickups and deliveries after a warning
- Not sending required macros
- Less than one week''s notice for time off
- Paperwork not turned in by midnight Monday
- Not telling Dispatch about demurrage or excess heel
- Driving out of route without permission
- Not reporting damage to the truck or trailer

The Pay Plan lists the exact reduction for each one.

*Source: Pay Plan p. 3, p. 4, p. 5*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (77, 'Pay plan details', 'How does the fuel bonus work, and where should I fuel?',
   'You earn a fuel bonus on every driving hour by buying fuel in the approved network whenever one is reasonably close. Best discounts are at the Plattsmouth Yard and Barto Yard. Next best are Love''s, Sapp Bros. and Bosselman Travel Centers, including the Pilot in Grand Island. Then Kwik Trip / Kwik Star and QT. If you need to fuel outside the network, call Dispatch or Safety for approval first when you can. Out-of-network fueling won''t cut your bonus if Dispatch told you to, it was approved, there was a fuel card problem or an emergency, or no network stop was reasonably close.

*Source: Pay Plan p. 1, p. 4*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (78, 'Pay plan details', 'How is the production bonus figured?',
   'At the end of each quarter, drivers are ranked by production, which is revenue earned minus fuel cost. The higher your rank, the more is added to your rate for the next quarter. The bottom 20% get nothing added. You have to still be employed when the next quarter starts.

*Source: Pay Plan p. 3*',
   '[]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (79, 'Pay plan details', 'How is the idle-time bonus figured?',
   'The further your truck''s idle time is below 40% of engine hours, the more is added to your rate for the next quarter, up to the plan maximum. For example, a truck with 100 engine hours, 60 driving and 40 idling, has 40% idle time and earns nothing. The fleet goal is 20% idle time or less, which earns the full amount.

*Source: Pay Plan p. 3*',
   '[]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (80, 'Pay plan details', 'How can my hourly rate go up?',
   'After your first full quarter, your production and idle-time results can raise your rate for the next quarter (FAQs 78 and 79). Years-of-service pay is added on top of that (FAQ 24). PTO is separate.

*Source: Pay Plan p. 1, p. 3*',
   '[]'::jsonb, 90, 'Jason Eisenman', 'Jason Eisenman'),
  (81, 'Pay plan details', 'Is there a bonus for referring a driver?',
   'Yes. It''s paid in monthly payments over five months, starting with the first payroll after the driver you referred has had a truck for one month. Payments stop if either of you leaves the company.

*Source: Pay Plan p. 2*',
   '[]'::jsonb, 100, 'Jason Eisenman', 'Jason Eisenman'),
  (82, 'Pay plan details', 'Do I get paid for a clean DOT inspection?',
   'Yes. You get a payment on your paycheck plus Drive for Gold points.

*Source: Pay Plan p. 2*',
   '[]'::jsonb, 110, 'Jason Eisenman', 'Jason Eisenman'),
  (83, 'Pay plan details', 'How do I get reimbursed for expenses?',
   'Get a manager''s approval before you spend the money. Then submit the expense, with the receipt, on an Additional Paysheet in DeliveRecon.

*Source: Pay Plan p. 2*',
   '[]'::jsonb, 120, 'Jason Eisenman', 'Jason Eisenman'),
  (84, 'Pay plan details', 'What is Drive for Gold?',
   'It''s a rewards program. You earn points for completing safety training, and management can give points for customer compliments or going above and beyond. Points can be cashed out or used for merchandise. You get an invitation during orientation and create your own login.

*Source: Pay Plan p. 2*',
   '[{"label": "Drive for Gold rewards", "url": "https://www.liquidtruckingrewards.com"}]'::jsonb, 130, 'Jason Eisenman', 'Jason Eisenman'),
  (85, 'Pay plan details', 'My ELD isn''t working. How do I get paid for drive time?',
   'Use paper logs until maintenance fixes it. Paper logs have to reach Payroll by midnight Monday to count on that Friday''s check.

*Source: Pay Plan p. 3*',
   '[]'::jsonb, 140, 'Jason Eisenman', 'Jason Eisenman'),
  (86, 'Pay plan details', 'Can I change my logged time to drive time?',
   'No. The company report shows any time on-duty, off-duty or sleeper time is changed to drive time by hand. Changing drive time on purpose can cost you the safety bonus for up to a year, and can lead to termination.

*Source: Pay Plan p. 3*',
   '[]'::jsonb, 150, 'Jason Eisenman', 'Jason Eisenman'),
  (26, '401(k) retirement', 'When can I join the 401(k)?',
   'You''re enrolled automatically on the first of the month after you finish 6 months of service, as long as you''re 19 or older by then. For example, if you''re hired March 10, you''re enrolled October 1. About a month before, around 5 months of service, John Hancock mails you a packet with instructions to set up your online account.

*Source: Guide p. 21, Payroll FAQ p. 4, confirmed by Jason Nov 4, 2026*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (27, '401(k) retirement', 'Am I signed up automatically?',
   'Yes. 5% of your pay goes in automatically, before taxes, and is invested in a target date fund that matches your age. Each year on your work anniversary it goes up 1%, until it reaches 10%. You can change any of this at any time.

*Source: Guide p. 21*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (28, '401(k) retirement', 'Does the company match what I put in?',
   'Yes. The company currently matches 50% of the first 5% of eligible pay that you put in. If you put in 5%, the company adds 2.5%, which is the most it matches. The plan may also make a profit-sharing contribution at year end.

*Source: Guide p. 21, Payroll FAQ p. 4*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (29, '401(k) retirement', 'How do I change how much I put in, or switch to Roth?',
   'Log in to your John Hancock account online or call 1-800-294-3575. Money goes in pre-tax unless you choose Roth on the website, and you can split it between the two. The 2026 limits are $24,500, or $32,500 if you''re 50 or older, or $35,750 if you''re 60-63.

*Source: Guide p. 21, Payroll FAQ p. 4*',
   '[{"label": "John Hancock", "url": "https://www.johnhancock.com/myplan"}, {"label": "401(k) video", "url": "https://www.brainshark.com/usi/vu?pi=zHLz1951MmzgpMPz0"}]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (30, '401(k) retirement', 'When does the company''s money become mine (vesting)?',
   'Money you put in is always yours. The company match and profit sharing become yours over time:

| Years of service | Yours |
| --- | --- |
| 1 | 0% |
| 2 | 20% |
| 3 | 40% |
| 4 | 60% |
| 5 | 80% |
| 6 | 100% |

Everything is fully yours at age 62.

*Source: Guide p. 21*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (31, '401(k) retirement', 'Can I move an old 401(k) into this plan?',
   'Yes. You can roll a 401(k) from a previous job into this plan.

*Source: Guide p. 21*',
   '[{"label": "John Hancock", "url": "https://www.johnhancock.com/myplan"}]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (32, '401(k) retirement', 'When can I take money out? Can I borrow from it?',
   'You can take your money if you leave the company, retire, become disabled, or at death. While you''re still working here, you can take it out after age 59½, and hardship withdrawals of your own contributions are allowed. Loans are allowed up to 50% of your vested balance or $50,000, whichever is less. For advice, call the plan''s advisors at USI, Derek Bailey or Kim Thomas, at 800-284-7142.

*Source: Guide p. 21*',
   '[]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (33, 'Enrolling and eligibility', 'Who can get benefits?',
   'All full-time employees who work 30 or more hours a week.

*Source: Guide p. 5*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (34, 'Enrolling and eligibility', 'I''m new. When do I sign up, and when does coverage start?',
   'You have 30 days from your start date to enroll. Coverage starts on the first of the month after 30 days of continuous, active work. Think carefully before you turn anything down: some coverage is guaranteed only the first time you''re offered it, with no health questions. Later, you may have to answer health questions and could be turned down. Most coverage also requires that you be actively at work on the day it starts.

*Source: Guide p. 2, p. 5, p. 17, p. 18*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (35, 'Enrolling and eligibility', 'How do I enroll?',
   'Enroll online in Paycor, or by phone with a benefits expert at 1-855-447-4726 ext. 4485. Phone hours are Monday-Thursday 7 am-7 pm and Friday 7 am-5 pm, Central time.

*Source: Guide p. 3*',
   '[{"label": "Paycor", "url": "https://www.paycor.com"}, {"label": "Benefits website", "url": "https://www.cbmicrosite.com/liquidtrucking"}]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (36, 'Enrolling and eligibility', 'When is open enrollment, and can I change my benefits during the year?',
   'Open enrollment happens once a year, usually in the spring. For 2026 it runs May 25-June 12, and changes take effect July 1, 2026. Everyone has to complete it. Between open enrollments, you can only change benefits within 30 days of a qualifying life event, such as:

- Marriage, divorce, legal separation, or the death of a spouse
- Birth, adoption, or the death of a child
- A change in a child''s dependent status
- A move to a new home
- A change in your job status, or in coverage through another employer''s plan

*Source: Guide p. 2, p. 3*',
   '[]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (37, 'Enrolling and eligibility', 'Who can I put on my medical, dental and vision?',
   '- Your legal spouse. Common-law spouses and domestic partners don''t qualify.
- Your children under 26, including natural, step, foster and adopted children, and children under your legal guardianship.

Life insurance has its own rules (see FAQ 56).

*Source: Guide p. 5*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (38, 'Enrolling and eligibility', 'My spouse can get insurance at their job. Can I still put them on our medical plan?',
   'No. A spouse who is offered medical insurance by their own employer can''t be on our medical plan. To keep your spouse covered, you have to fill out a Working Spouse Provision Form, or their coverage will end. If your spouse''s job changes during the year, fill out an updated form. The form is in Paycor, or ask HR.

*Source: Guide p. 5*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (39, 'Enrolling and eligibility', 'How much do benefits cost?',
   'Premiums come out of your weekly paycheck, 52 times a year.

| Weekly cost | Medical | Dental | Vision |
| --- | --- | --- | --- |
| Employee only | $40.00 | $4.26 | $1.52 |
| Employee + spouse | $145.00 | $13.48 | $2.89 |
| Employee + child(ren) | $125.00 | $13.48 | $3.04 |
| Family | $170.00 | $13.48 | $4.47 |

Basic Life/AD&D and short-term disability are free. For voluntary life, long-term disability, accident, critical illness and hospital coverage, log in to Paycor to see your personal rates.

*Source: Guide p. 6*',
   '[]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (40, 'Enrolling and eligibility', 'What changed for 2026?',
   '- **Medical:** still Point C Health, with small changes to the plan and to what employees pay.
- **Dental:** still Ameritas, with no rate changes.
- **Vision:** now Mutual of Omaha, using the same EyeMed Insight network. It costs less and has a $150 frame allowance.
- **Life, disability, accident, critical illness and hospital coverage:** now through Mutual of Omaha.
- **2026 only:** voluntary life up to $200,000 (spouse $50,000, children $10,000) and long-term disability with no health questions.

*Source: Guide p. 3*',
   '[]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (41, 'Medical and prescriptions', 'What does the medical plan cover?',
   'The medical plan is through Point C Health. In-network costs:

|  | You pay |
| --- | --- |
| Yearly deductible | $3,000 individual / $6,000 family |
| After the deductible | 20% (the plan pays 80%) |
| Most you pay in a year | $6,000 individual / $12,000 family |
| Preventive care | Nothing, covered 100% |
| Telemedicine (Teladoc) | $10 |
| Primary care visit | $30 |
| Specialist visit | $50 |
| Urgent care | $50 |
| Emergency room | $300 for an emergency, $750 if it isn''t one. Waived if you''re admitted. |
| X-rays and lab tests | 20% after deductible; in a clinic or independent lab, the $30 or $50 office copay applies |
| Complex imaging, hospital stays, outpatient surgery | 20% after deductible |

The full details are in the Summary Plan Description in Paycor. If anything here conflicts with it, the Summary Plan Description wins.

*Source: Guide p. 11, ER copay confirmed by Jason Nov 4, 2026*',
   '[{"label": "Point C portal", "url": "https://portal.pointctpa.com"}]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (42, 'Medical and prescriptions', 'Which doctors and hospitals can I use?',
   'You can use any doctor or hospital. Two programs get lower, set prices, so using them saves you money:

- **Elite Choice:** Omaha, Council Bluffs, Lincoln and Fremont. It includes Methodist Health System, Bryan Medical Center, Methodist Fremont Health, and more than 2,000 practitioners.
- **Valenz Access:** providers in many states. In Omaha it includes Children''s Hospital, Nebraska Medical Center, Bellevue Medical Center and the Fred & Pamela Buffett Cancer Center.

If you live outside those areas, it''s often cheaper to travel to a metro area for care. To find a provider, call Valenz at 800-441-7705.

*Source: Guide p. 8, p. 11*',
   '[{"label": "Elite Choice list", "url": "https://liquidtrucking.claimsbridge.com"}, {"label": "Valenz member portal", "url": "https://member.valenzhealth.com"}]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (43, 'Medical and prescriptions', 'How do I search for a provider on the Valenz website?',
   '1. Log in to the Valenz member portal.
2. Search by provider name, specialty, type of facility, or service. Results start near your computer''s location.
3. To search somewhere else, click **Refine search**, uncheck **My location**, and enter another address.
4. Narrow the results by network, language, gender, quality rating, or cost rating. **Valenz Access** providers are in network. **Valenz Friendly** providers aren''t contracted, but they have accepted Valenz payments before.

*Source: Guide p. 9*',
   '[{"label": "Valenz member portal", "url": "https://member.valenzhealth.com"}]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (44, 'Medical and prescriptions', 'What is reference-based pricing, and how does it affect me?',
   'Many hospitals mark up their prices far beyond what care actually costs. Our plan pays hospitals a fair price based on what a service really costs, plus a reasonable profit. That keeps premiums lower. You still pay your normal deductible, copays and coinsurance. At a doctor''s office or pharmacy, you pay your copay as usual. After a visit to a hospital, ER, clinic or other facility, you''ll get an Explanation of Benefits (EOB) in the mail that shows what you owe.

*Source: Guide p. 7*',
   '[{"label": "Overpriced toothbrush video", "url": "http://bit.ly/overpricedtoothbrush"}, {"label": "Video 2", "url": "https://www.youtube.com/watch?v=IE_906IijLw"}, {"label": "Video 3", "url": "https://www.youtube.com/watch?v=24drfWhaF14"}]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (45, 'Medical and prescriptions', 'I got a bill for more than my EOB says I owe. What do I do?',
   'Only pay what your EOB says. Don''t pay any other amount until it''s been checked. If you get a bill for more than your EOB shows (a "balance bill"), call NaVcare (Valenz Health) at 800-441-7705. It''s your responsibility to make that call.

*Source: Guide p. 7, p. 4*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (46, 'Medical and prescriptions', 'Do I need approval before a surgery or hospital stay?',
   'Yes. Pre-certification is required before any scheduled hospital stay, and before outpatient surgery that isn''t done in a doctor''s office. It''s also recommended before chemotherapy, CT scans, MRIs, MRAs, PET scans, radiation, home health care, all medical equipment rentals, and equipment purchases over $1,200. If you''re admitted through the emergency room, notify them within 2 business days. If you skip pre-certification, you''ll owe a $500 penalty. To pre-certify, call NaVcare (Valenz Health) at 800-441-7705.

*Source: Guide p. 10*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (47, 'Medical and prescriptions', 'Is there a bonus for talking to HR before surgery?',
   'Yes. You get $100 if you contact and meet with HR before you schedule any surgery. Conditions apply, so ask HR for details.

*Source: Guide p. 10*',
   '[]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (48, 'Medical and prescriptions', 'What do prescriptions cost?',
   '|  | Retail (30 days) | Mail order (90 days) |
| --- | --- | --- |
| Generic | $10 | $30 |
| Preferred brand | $45 | $135 |
| Non-preferred brand | $70 | $210 |
| Specialty | Not covered (see FAQ 49) | Not covered |

*Source: Guide p. 11*',
   '[]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (49, 'Medical and prescriptions', 'My specialty medication isn''t covered. What now?',
   'The health plan doesn''t cover specialty drugs, but Point C Rx Solutions can help you get them for less. If you''re prescribed one, Point C Rx Care Management will contact you. To start sooner, call them at (872) 265-4700 or email caremanagement@pointchealth.com.

*Source: Guide p. 12, p. 4*',
   '[]'::jsonb, 90, 'Jason Eisenman', 'Jason Eisenman'),
  (50, 'Medical and prescriptions', 'Can I use GoodRx instead of my insurance?',
   'Yes. Sometimes a coupon like GoodRx costs less than your copay. You can use the coupon or your insurance for a prescription, but not both. If you use the coupon, that cost doesn''t count toward your deductible or yearly maximum. You can get a GoodRx card at the Safety & HR Office.

*Source: Guide p. 12*',
   '[{"label": "GoodRx", "url": "https://www.goodrx.com"}]'::jsonb, 100, 'Jason Eisenman', 'Jason Eisenman'),
  (51, 'Everyday care, dental and vision', 'Can I see a doctor by phone or video?',
   'Yes. If you''re on the medical plan, Teladoc connects you with U.S. board-certified doctors by phone, computer or the Teladoc app for $10. You can use it from anywhere, including on the road. It''s good for colds and flu, allergies, sore throat, pink eye, ear infections, urinary tract infections, and short-term prescription refills. The doctor can send a prescription to a nearby pharmacy, though that isn''t available in every state. Call 800-835-2362.

*Source: Guide p. 13, p. 11*',
   '[{"label": "Teladoc", "url": "https://www.teladoc.com"}]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (52, 'Everyday care, dental and vision', 'Where should I go for care: telemedicine, urgent care or the ER?',
   'Picking the right place can save you money:

| Where | Good for | You pay |
| --- | --- | --- |
| Nurse line (through your doctor''s office) | Questions such as "how long should I ice this?", or where to go for care | Nothing |
| Telemedicine (Teladoc) | Colds, flu, allergies, rashes, pink eye, coughs | $10 |
| Primary care doctor | Checkups, shots, ongoing conditions, illness | $30 |
| Urgent care | Minor accidents, sprains, small fractures, cuts and burns | $50 |
| Emergency room | Chest pain, trouble breathing, head injuries, heavy bleeding, seizures, broken bones | $300 ($750 if not an emergency) |

*Source: Guide p. 14, p. 11*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (53, 'Everyday care, dental and vision', 'What does dental cover?',
   'Dental is through Ameritas. There''s no deductible and a $1,500 yearly maximum.

|  | Plan pays |
| --- | --- |
| Preventive | 100% |
| Basic | 80% |
| Major | 50% |
| Orthodontia (children under 19 only) | 50%, up to $1,000 lifetime |

Call 800-659-2223 to find a dentist.

*Source: Guide p. 16*',
   '[{"label": "Ameritas", "url": "https://www.ameritas.com"}]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (54, 'Everyday care, dental and vision', 'What does vision cover?',
   'Vision is through Mutual of Omaha, on the EyeMed Insight network.

|  | You pay or get | How often |
| --- | --- | --- |
| Eye exam | $10 | Every 12 months |
| Lenses | $25 | Every 12 months |
| Contacts (instead of lenses) | $150 allowance | Every 12 months |
| Frames | $150 allowance | Every 24 months |

Call 833-279-4358 to find an eye doctor.

*Source: Guide p. 16*',
   '[{"label": "Mutual of Omaha Vision", "url": "https://www.mutualofomaha.com/vision"}]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (55, 'Life, disability and supplemental insurance', 'Does the company give me life insurance?',
   'Yes. Every full-time employee gets $20,000 of life insurance and accidental death and dismemberment (AD&D) coverage through Mutual of Omaha, at no cost. AD&D pays an extra benefit if you die or suffer a serious covered injury in an accident.

*Source: Guide p. 3, p. 17*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (56, 'Life, disability and supplemental insurance', 'Can I buy more life insurance for me or my family?',
   'Yes, through Mutual of Omaha:

| Who | Up to | No health questions up to\* |
| --- | --- | --- |
| You | 5x your salary, max $500,000, in $10,000 steps | $200,000 |
| Spouse | $250,000, but no more than your own amount | $50,000 |
| Children | $10,000 | $10,000 |

\*Only if you sign up when you''re first eligible, or during 2026 open enrollment, which is a one-time chance for everyone. You have to enroll yourself to cover family members. A spouse''s coverage may end at age 70. A child''s coverage ends at 26, or earlier if they marry, work full time or stop being a full-time student. Amounts may go down after age 65. Your rates are in Paycor.

*Source: Guide p. 3, p. 17*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (57, 'Life, disability and supplemental insurance', 'What if I can''t work because I''m sick or hurt off the job?',
   'Disability insurance through Mutual of Omaha replaces part of your pay:

|  | Short-term disability | Long-term disability |
| --- | --- | --- |
| Pays | 60% of earnings, up to $1,500 a week | 60% of earnings, up to $5,000 a month |
| Starts | After 7 days | After 90 days |
| Lasts | Up to 12 weeks | Up to Social Security retirement age |

Short-term disability doesn''t cover injuries or illness from work. If you skip disability coverage when you''re first eligible, you''ll have to answer health questions to get it later. Claims for a condition you already had before coverage started may be denied. Short-term disability is free; the company pays for it. Long-term disability is paid by you, and your rate is in Paycor.

*Source: Guide p. 3, p. 18, cost confirmed by Jason Nov 4, 2026*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (58, 'Life, disability and supplemental insurance', 'Why should I update my beneficiaries?',
   'Your beneficiaries are the people who get your life insurance if you die. If they''re out of date, it''s hard to pay the right person. Check them every open enrollment, and after a marriage, divorce or new child. You can update them in Paycor.

*Source: Guide p. 3, p. 17*',
   '[]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (59, 'Life, disability and supplemental insurance', 'What are Accident, Critical Illness and Hospital Indemnity insurance?',
   'They''re optional plans through Mutual of Omaha that pay cash to you:

- **Accident:** pays for injuries from accidents that aren''t work-related, such as fractures, dislocations, concussions and cuts. It also helps with ambulance rides, ER visits, surgery, follow-up care, travel and lodging. The amount depends on the injury.
- **Critical Illness:** pays a lump sum if you''re diagnosed with a covered condition, such as cancer, heart attack, stroke, major organ failure or certain nerve diseases. Up to $50,000 for you, $50,000 for a spouse, and $13,000 for a child.
- **Hospital Indemnity:** pays $1,000 when you''re admitted to the hospital, plus $100 a day while you''re there, including for having a baby.

Your rates are in Paycor.

*Source: Guide p. 3, p. 19*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (60, 'Life, disability and supplemental insurance', 'What is the $100 wellness benefit?',
   'The Accident, Critical Illness and Hospital Indemnity plans each pay you $100 a year when you get a qualifying health screening or test, such as a yearly checkup. If you have all three, that''s up to $300.

*Source: Guide p. 3, p. 19*',
   '[]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (61, 'Extra support and perks', 'Is there free, private counseling for me and my family?',
   'Yes. The Employee Assistance Program (EAP) through Mutual of Omaha is free for full-time employees and their immediate family. It''s open 24/7, every day of the year, in more than 120 languages.

- Up to 3 counseling sessions a year per household, in person or by text, chat, phone or video.
- One of those sessions can be used for a 30-minute legal or financial consultation.
- A 25% discount on ongoing legal services, plus legal forms and tools.
- Help finding childcare and elder care, and support with family, relationships and money.

Call 1-800-316-2796.

*Source: Guide p. 15, p. 20*',
   '[{"label": "Mutual of Omaha EAP", "url": "https://www.mutualofomaha.com/eap"}]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (62, 'Extra support and perks', 'Is there help if I have a problem while traveling?',
   'Yes. Travel Assistance (AXA Assistance USA) helps when you''re more than 100 miles from home or outside the country. In the U.S., call 1-800-856-9947. Outside the U.S., call collect at (312) 935-3658. It''s included with the company life insurance.

*Source: Guide p. 20*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (63, 'Extra support and perks', 'Can I make a will for free?',
   'Yes. Online will preparation tools let you create a basic will and other documents in a few clicks. It''s included with the company life insurance.

*Source: Guide p. 20*',
   '[{"label": "Will preparation", "url": "https://www.willprepservices.com"}]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (64, 'Extra support and perks', 'Is there a hearing aid discount?',
   'Yes. If you have any Mutual of Omaha coverage, you and your family get discounts on hearing aids and batteries. Call 1-888-534-1747.

*Source: Guide p. 20*',
   '[{"label": "Amplifon hearing discount", "url": "https://www.amplifonusa.com/mutualofomaha"}]'::jsonb, 40, 'Jason Eisenman', 'Jason Eisenman'),
  (65, 'Extra support and perks', 'I''ve been diagnosed with a serious condition. Is there someone who can help me sort it out?',
   'If you have Critical Illness coverage, the Advocacy service gives you one-on-one help from nurses and clinicians. Call 1-866-372-5577, Monday-Friday 7 am-7 pm Central, or email customerserve@personifyhealth.com.

*Source: Guide p. 20*',
   '[]'::jsonb, 50, 'Jason Eisenman', 'Jason Eisenman'),
  (66, 'Extra support and perks', 'Do we get employee discounts?',
   'Yes. PerkSpot has more than 30,000 discounts on things like movie tickets, electronics, travel, cell phones, cars and more, for you and your family. If it asks for your community, pick **Cottingham and Butler**.

*Source: Guide p. 22*',
   '[{"label": "PerkSpot", "url": "https://cottinghambutler.perkspot.com"}]'::jsonb, 60, 'Jason Eisenman', 'Jason Eisenman'),
  (67, 'Extra support and perks', 'Can someone help me with Social Security, Medicare, Medicaid, disability or veterans benefits?',
   'Yes. FEDlogic gives free, private, unlimited advice on government benefits to you and your household, even if you aren''t on our benefits. They don''t sell anything. Call 877-837-4196 to set up a phone appointment of about an hour, or email services@fedlogicgroup.com.

*Source: Guide p. 23*',
   '[{"label": "FEDlogic", "url": "https://www.fedlogicgroup.com"}]'::jsonb, 70, 'Jason Eisenman', 'Jason Eisenman'),
  (68, 'Extra support and perks', 'I''m getting close to retirement. Who can help me with Medicare?',
   'Next Level Planning offers free help from licensed agents, with no obligation to buy. They can compare Medicare plans and help with retirement and financial planning. Call (414) 369-6620.

*Source: Guide p. 24*',
   '[{"label": "Next Level Planning", "url": "https://www.nlpm.com"}, {"label": "Ask them to call you", "url": "https://app.smartsheet.com/b/form/9f83ac0937fe480b8d110c7c09a77ed3"}]'::jsonb, 80, 'Jason Eisenman', 'Jason Eisenman'),
  (69, 'Contacts and full documents', 'Who do I contact with a benefits question?',
   'Call HR at (402) 298-7031 or email benefits@liquidtrucking.com. The benefits website also has more details.

*Source: Guide p. 4*',
   '[{"label": "Benefits website", "url": "https://www.cbmicrosite.com/liquidtrucking"}]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman'),
  (70, 'Contacts and full documents', 'What are the phone numbers for each benefit?',
   '| Benefit | Company | Phone |
| --- | --- | --- |
| Medical claims and questions | Point C Health | (800) 364-9505 |
| Finding a provider, pre-certification, billing help | Valenz Health (NaVcare) | (800) 441-7705 |
| Specialty medication help | Point C Rx Care Management | (872) 265-4700 |
| Telemedicine | Teladoc | (800) 835-2362 |
| Dental | Ameritas | (800) 659-2223 |
| Vision | Mutual of Omaha (EyeMed) | (833) 279-4358 |
| Life, disability, accident, critical illness, hospital | Mutual of Omaha | (800) 877-5176 |
| Counseling (EAP) | Mutual of Omaha | 1-800-316-2796 |
| Government benefits help | FEDlogic | (877) 837-4196 |
| 401(k) | John Hancock | (800) 294-3575 |
| Enrolling by phone | Benefits expert | 1-855-447-4726 ext. 4485 |

*Source: Guide p. 3, p. 4, p. 15*',
   '[]'::jsonb, 20, 'Jason Eisenman', 'Jason Eisenman'),
  (71, 'Contacts and full documents', 'Where can I read the full Benefits Guide and the legal notices?',
   'The full 2026-2027 Benefits Guide is attached to this FAQ. Pages 26-32 have the required notices, such as HIPAA privacy, Medicare Part D, and premium help through Medicaid and CHIP. The guide is a summary. The Summary Plan Description has the complete details, and it wins if the two ever disagree. You can get it in Paycor or from HR.

*Source: Guide p. 2, p. 26-32*',
   '[]'::jsonb, 30, 'Jason Eisenman', 'Jason Eisenman'),
  (115, 'For recruiters', 'What should I cover with every new lead?',
   '1. Location. Check the Hiring Map to see whether we''re hiring in their area right now.
2. Home time for their area
3. Experience
4. Hazmat and tanker endorsements. Denver drivers must already have Hazmat. Chicago drivers without Hazmat should know about the scheduling and fingerprint timing.
5. MVR. If they mention problems, find out what they were and when.
6. Pet policy. Suggested wording: "Because of the food-grade and Kosher products we haul, pets aren''t allowed to ride along. Would that be an issue for you?"
7. Contact information

*Source: FAQ Sheet p. 7*',
   '[]'::jsonb, 10, 'Jason Eisenman', 'Jason Eisenman')
on conflict (id) do nothing;

-- Keep new FAQs numbered after the imported ones.
select setval(pg_get_serial_sequence('public.faq', 'id'), greatest((select max(id) from public.faq), 1));

-- History: one "Imported" entry per FAQ (skipped if it's already there).
insert into public.faq_versions (faq_id, version, action, reason, before, after, by_email, by_name, at)
select f.id, f.version, 'imported',
       'Imported from the original FAQ documents (Payroll FAQ, Regional Driver Pay Plan, 2026-2027 Benefits Guide, FAQ Sheet)',
       null, public.faq_snap(f), 'jason@liquidtrucking.com', 'Jason Eisenman', f.created_at
from public.faq f
where not exists (select 1 from public.faq_versions v where v.faq_id = f.id);

select count(*) as faqs_loaded from public.faq;
