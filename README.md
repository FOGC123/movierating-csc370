# CSC 370 - Movie Rating Database (Group 19)

**Course:** CSC370: Database Systems  
**Project:** Movie Rating System  

---

## Team Members
* Aaron Lin
* Oliver Cooper
* Mayra Gonzalez Martinez
* Karanveer Singh

---

## Sprint 0: Kick-Off Summary
For this initial kick-off sprint, we established the foundational data architecture for our movie rating database:
* **Conceptual Modeling:** Designed a complete Entity-Relationship Diagram (ERD) defining core entities (`movie`, `cast_crew`, `account`) and relationships (`worked_on`, `review`).
* **BCNF Normalization:** Formally analyzed functional dependencies across all relations to ensure full compliance with Boyce-Codd Normal Form (BCNF), avoiding data anomalies.
* **SQL DDL Implementation:** Implemented and validated the relational schema in MySQL using formal DDL (`initial-schema.sql`) with domain and check constraints.

---

## Repository Structure
* `initial-schema.sql`: Executable MySQL DDL script containing table definitions, primary keys, foreign keys, and constraints.
* `entity_relationship_diagram.jpg`: ERD diagram.
