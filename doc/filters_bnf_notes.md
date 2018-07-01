Filter BNF
===

```
filters := filter*

filter := positive_filter | negative_filter

positive_filter := textvalued | boolvalued | numbervalued | anyfield

negative_filter := negation_atom positive_filter

negation_atom :=
   "-" | "NOT"


// ANYFIELD
anyfield := textoperands // contains search of any of name, address, crossStreet, postalCode, category, twitter, phone

// TEXT
textvalued_binary := textfields binary_text_operators textoperands
textvalued_unary  := textfields unary_text_operators

textfields :=
  | "name"
  | "address"
  | "crossStreet"
  | "postalCode" | "zip"    // same meaning
  | "city"
  | "twitter"
  | "phone"
  | "url"
  | "category" | "cat"          // only first category
  | "location"         // location means any of name, address, crossStreet, postalCode, city
  | "ratio"            // good,maybe,bad

binary_text_operators :=
   ":"                  // any of textfield matches any of textoperands
   | "="                // any of textfield exactly matches textoperands

unary_text_operators :=
   "[:|=|IS] *empty"   // any of textfield is empty or blank
   | "[:|=|IS] *missing"         // same as empty
   | "[:|=|IS] *blank"           // same as empty

textoperands :=
  STRING*         // list of bare, single quoted, or double quoted strings

// NUMBER

numbervalued_binary := numberfields binary_number_operators numberoperand

numberfields :=
  "users"
  | "checkins"
  | "herenow"
  | "tips"

binary_number_operators :=
  "="
  | "<"
  | "<="
  | ">"
  | ">="

numberoperand :=
  INTEGER // no non-int fields yet

// DATE VALUED

datevalued := datefields binary_number_operators dateoperand

datefields :=
  created_at

dateoperand :=
  string  // parsed by moment.js, parse failure there means parse failure here

// BOOLEAN

boolvalued :=
  "private"
  | "verified" | "claimed" // same meaning
  | "home" | "homes"
```
