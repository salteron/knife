# coding: utf-8

module RandomNameGenerator
  ADJECTIVES = %w(happy jolly dreamy sad angry pensive focused sleepy) +
               %w(grave distracted determined stoic stupefied sharp) +
               %w(agitated cocky tender goofy furious desperate) +
               %w(hopeful compassionate silly lonely condescending) +
               %w(kickass drunk boring nostalgic ecstatic insane) +
               %w(naughty cranky mad jovial sick hungry thirsty) +
               %w(elegant backstabbing clever trusting loving) +
               %w(suspicious berserk high romantic prickly evil)

  NAMES = %w(mestorf rosalind sinoussi carson mcmclintock yonath) +
          %w(wright lovelace franklin tesla einstein bohr davinci) +
          %w(lumiere pasteur nobel curie darwin turing ritchie) +
          %w(morse torvalds pike thompson wozniak galileo) +
          %w(mclean euclid newton fermat archimedes poincare) +
          %w(brown heisenberg feynman hawking fermi pare mccarthy) +
          %w(bardeen engelbart babbage albattani ptolemy bel ) +
          %w(brattain shockley goldstine hoover hopper bartik) +
          %w(sammet jones perlman wilson kowalevski hypatia) +
          %w(goodall mayer elion blackwell lalande kirch) +
          %w(ardinghelli colden almeida leakey meitner)

  def self.generate
    [ADJECTIVES.sample, NAMES.sample].join('-')
  end
end
