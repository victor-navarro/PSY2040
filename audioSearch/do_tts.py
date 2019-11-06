#define function
def tts(wlist, file_prefix):
    from google.cloud import texttospeech
    import os
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "C:/Users/vnavarro/Desktop/tts.json"
    client = texttospeech.TextToSpeechClient()

    for w in range(len(wlist)):

        # Set the text input to be synthesized
        synthesis_input = texttospeech.types.SynthesisInput(text=wlist[w])

        # Build the voice request, select the language code ("en-US") and the ssml
        # voice gender ("neutral")
        voice = texttospeech.types.VoiceSelectionParams(
            language_code='en-US',
            ssml_gender=texttospeech.enums.SsmlVoiceGender.NEUTRAL)

        # Select the type of audio file you want returned
        audio_config = texttospeech.types.AudioConfig(
            audio_encoding=texttospeech.enums.AudioEncoding.LINEAR16)

        # Perform the text-to-speech request on the text input with the selected
        # voice parameters and audio file type
        response = client.synthesize_speech(synthesis_input, voice, audio_config)

        # The response's audio_content is binary.
        filename = '%s%d.wav' % (file_prefix, w+1)
        with open('./sound_files/%s' % filename, 'wb') as out:
            # Write the response to the output file.
            out.write(response.audio_content)
            print('Audio content written to file "./sound_files/%s"' % filename)


#cycle through lists and generate the audio files
lists = ['target', 'distractor', 'unrelated']
for l in lists:
    with open('./word_lists/%s.txt' % l) as f:
        wlist = f.read().splitlines()
        tts(wlist, l[0].upper())

