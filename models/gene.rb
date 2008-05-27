require 'rubygems'
require 'statarray'

class Gene < DataMapper::Base

  # Each of these defines a accessor method for the class
  # and each also corresponds to a column in the database
  property :name,      :string
  property :sequence,  :text

  # Checks that the sequence has a start codon, a stop codon, and contains only ATGC
  validates_format_of :sequence, :with => /^ATG[ATGC\n]+(TAG|TAA|TGA)$/im

  def self.create_from_flatfile(entry)

    gene = Gene.new
    gene.name = entry.definition.split(/\s+/).first
    gene.sequence = entry.data

    if gene.valid?
      gene.save!
    else
      puts "#{gene.name} is not contain a valid sequence "
      # Could raise an error here instead
      # Or even better write to an error log
    end
  end

  def self.mean_length
    genes = Gene.find(:all)
    genes.map{|gene| gene.sequence.length}.to_statarray.mean
  end

  def self.sd_length
    genes = Gene.find(:all)
    genes.map{|gene| gene.sequence.length}.to_statarray.stddev
  end

  def self.bin_sequence_length(n_bins)
    lengths = Gene.find(:all).map{|gene| gene.sequence.length}
    min = lengths.min
    max = lengths.max
    bin_size = (max - min) / n_bins

    frequencies = Hash.new
    n_bins.times do |i|
      frequencies.store(Range.new(i*bin_size + min, i*bin_size + bin_size + min, true) , 0)
    end

    lengths.each do |length|
      frequencies.each_key { |range| frequencies[range] += 1 if range.include? length }
    end

    frequencies
    
  end

end
