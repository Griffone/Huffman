defmodule Huffman do
    @moduledoc """
    Griffone's implementation of Huffman encoding, a lossless compression algorithm.
    """

    @doc """
    A sample text for testing purposes.
    """
    def sample do
        'the quick brown fox jumps over the lazy dog
        this is a sample text that we will use when we build
        up a table we will only handle lower case letters and
        no punctuation symbols the frequency will of course not
        represent english but it is probably not that far off'
    end

    def text, do: 'this is something we should encode'

    @doc """
    Test the Huffman encoding
    """
    def test do
        sample = sample()
        tree = tree(sample)
        encode = encode_table(tree)
        decode = decode_table(tree)
        text = text()
        seq = encode(text, encode)
        decode(seq, decode)
    end

    @doc """
    Create a character frequency tree from given text sample.
    """
    def tree(sample) do
        huffman(reverse(freq(sample)))
    end

    @doc """
    Create an encoding table from given character frequency tree.
    """
    def encode_table(tree) do
        extractCharacters(tree)
    end

    @doc """
    Create a decoding table from given character frequency tree.
    """
    def decode_table(tree) do
        extractCharacters(tree)
    end

    @doc """
    Encode given text with given encoding table, effectively compressing it.
    """
    def encode([char | rest], table) do
        encodeChar(char, table) ++ encode(rest, table)
    end
    def encode([], table), do: []

    @doc """
    Decode a given compressed text with given decoding table, effectively decompressing it.
    """
    def decode([bit | rest], table) do
        decode([bit], rest, table)
    end
    def decode(curSeq, [bit | rest], table) do
        case decodeChar(curSeq, table) do
            {:found, char} ->
                [char] ++ decode([bit], rest, table)
            :notFound ->
                decode(curSeq ++ [bit], rest, table)
        end
    end
    def decode(curSeq, [], table) do
        case decodeChar(curSeq, table) do
            {:found, char} ->
                [char]
            :notFound ->
                raise "Failure to decode the sequence!" ++ curSeq
        end
    end

    @doc """
    Find a freqency list of given sample.
    """
    def freq(sample), do: freq(sample, [])
    def freq([], freq), do: freq
    def freq([char | rest], freq) do
        freq(rest, insertFreq(char, freq))
    end

    @doc """
    Insert a character into the frequency list, maintaining low to high ordering.
    """
    def insertFreq(char, []), do: [{char, 1}]
    def insertFreq(char, [ item | []]) do
        { storedChar, storedFreq } = item
        if char == storedChar do
            [ {storedChar, storedFreq + 1} ]
        else
            [ item, {char, 1}]
        end
    end
    def insertFreq(char, [ a, b | rest]) do
        { _, firstFreq } = a
        { storedChar, storedFreq } = b
        if storedChar == char do
            if storedFreq >= firstFreq do
                [{storedChar, storedFreq + 1}, a | rest]
            else
                [a, {storedChar, storedFreq + 1} | rest]
            end
        else
            [a | insertFreq(char, [b | rest])]
        end
    end

    @doc """
    Reverse a given list.
    """
    def reverse(list), do: reverse(list, [])
    def reverse([], list), do: list
    def reverse([head | tail], return) do
        reverse(tail, [head | return])
    end

    @doc """
    Generate a Huffman tree from a character frequency list.
    """
    def huffman([head | []]) do
        head
    end
    def huffman([a, b | rest]) do
        case a do
            { _, freq } ->
                aFreq = freq
            { _, _, freq } ->
                aFreq = freq
        end
        case b do
            { _, freq } ->
                bFreq = freq
            { _, _, freq } ->
                bFreq = freq
        end
        huffman(insertNode({ a, b, aFreq + bFreq }, rest))
    end

    @doc """
    Insert a given node into a list, used for constructing a Huffman tree.
    """
    def insertNode(node, []) do
        [node]
    end
    def insertNode(node, [head | rest]) do
        {_, _, nodeFreq} = node
        case head do
            {_, freq} ->
                headFreq = freq
            {_, _, freq} ->
                headFreq = freq
        end
        if nodeFreq <= headFreq do
            [node, head | rest]
        else
            [head | insertNode(node, rest)]
        end
    end

    @doc """
    Extracts characters from the tree.
    """
    def extractCharacters(tree), do: extractCharacters(tree, [], [])
    def extractCharacters({char, _}, chars, path) do
        [{char, path} | chars]
    end
    def extractCharacters({left, right, _}, chars, path) do
        extractCharacters(right, extractCharacters(left, chars, path ++ [0]), path ++ [1])
    end

    @doc """
    Encode a single character using an encoding table.
    """
    def encodeChar(char, [{tableChar, seq} | rest]) do
        if char == tableChar do
            seq
        else
            encodeChar(char, rest)
        end
    end
    def encodeChar(char, []) do
        raise "Character " ++ char ++ " was not found in the encoding table!"
    end

    @doc """
    Decode a single character using a decoding table.
    """
    def decodeChar(charSeq, [{tableChar, seq} | rest]) do
        if cmpSeq(charSeq, seq) do
            {:found, tableChar}
        else
            decodeChar(charSeq, rest)
        end
    end
    def decodeChar(charSeq, []), do: :notFound

    @doc """
    Sorts the decoding table, so that shortest characters sequences come before longer ones.
    """
    def sortDecode([a, b | rest]) do
        {_, seqA} = a
        {_, seqB} = b
        if isShorter(seqB, seqA) do
            [b | sortDecode([a | rest])]
        else
            [a | sortDecode([b | rest])]
        end
    end
    def sortDecode([a | []]), do: [a]

    @doc """
    Checks if sequence a is shorter than b.
    Used by sortDecode.
    """
    def isShorter([_ | a], [_ | b]), do: isShorter(a, b)
    def isShorter([], _), do: true
    def isShorter(_, []), do: false

    @doc """
    Compare 2 char sequences, returns true if the sequences are the same or false otherwise
    """
    def cmpSeq([chA | a], [chB | b]) do
        if chA == chB do
            cmpSeq(a, b)
        else
            false
        end
    end
    def cmpSeq([], []), do: true
    def cmpSeq([], _), do: false
    def cmpSeq(_, []), do: false

end