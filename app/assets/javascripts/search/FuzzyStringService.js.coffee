class FuzzyStringService
  @stringMap:
    'α': 'a'
    'β': 'v'
    'γ': 'g'
    'δ': 'd'
    'ε': 'e'
    'ζ': 'z'
    'η': 'i'
    'θ': 'th'
    'ι': 'i'
    'κ': 'k'
    'λ': 'l'
    'μ': 'm'
    'ν': 'n'
    'ξ': 'ks'
    'ο': 'o'
    'π': 'p'
    'ρ': 'r'
    'σ': 's'
    'τ': 't'
    'υ': 'u'
    'φ': 'f'
    'χ': 'h'
    'ψ': 'ps'
    'ω': 'o'
    'ς': 's'
    'ά': 'a'
    'έ': 'e'
    'ή': 'i'
    'ί': 'i'
    'ό': 'o'
    'ύ': 'y'
    'ώ': 'o'
    'ϊ': 'i'
    'ϋ': 'y'
    'ΐ': 'i'
    'ΰ': 'u'

  @fuzzyString: (string) ->
    result = @articleRemoval @greeklishToEnglish string.toLocaleLowerCase()
    result

  @articleRemoval: (text) ->
    text
      .replace( /^(the|an?|to|ta|o|i|el|la) /i, "")
      .replace( /[\.,-\/#!$%\^&\'\"\*;:{}@=–\-_<>`~()\s]/ig, "") # This is a dirty hack. Let's see if it works.

  @greeklishToEnglish: (text) ->
    for own k, v of @stringMap
      text = text.replace(new RegExp(k, 'g'), v)  # In this special case, no need for RegExp escaping
    text


window.FuzzyStringService = FuzzyStringService
