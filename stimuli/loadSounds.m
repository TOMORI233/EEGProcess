function [sounds, fs] = loadSounds(protocolID)
    interval = 0.6;

    switch protocolID
        case 1 % passive section 1 (different basic ICI): code 31~38
            [sounds{1}, fs] = audioread('sounds\interval 0\4.06_Reg.wav');
            sounds{2} = audioread('sounds\interval 0\8.12_Reg.wav');
            sounds{3} = audioread('sounds\interval 0\16.24_Reg.wav');
            sounds{4} = audioread('sounds\interval 0\32.48_Reg.wav');
            sounds{5} = audioread('sounds\interval 0\4.06_Irreg.wav');
            sounds{6} = audioread('sounds\interval 0\8.12_Irreg.wav');
            sounds{7} = audioread('sounds\interval 0\16.24_Irreg.wav');
            sounds{8} = audioread('sounds\interval 0\32.48_Irreg.wav');
            sounds = cellfun(@(x) x(1:min(fix(2 * fs), length(x))), sounds, 'UniformOutput', false);

        case 2 % passive section 2 (different variance): code 61~63
            [sounds{1}, fs] = audioread('sounds\variance diff\2.wav');
            sounds{2} = audioread('sounds\variance diff\50.wav');
            sounds{3} = audioread('sounds\variance diff\100.wav');
            sounds = cellfun(@(x) x(1:min(fix(2 * fs), length(x))), sounds, 'UniformOutput', false);

        case 3 % passive section 3 (one sound): code 91~98
            [sounds{1}, fs] = audioread('sounds\interval 0\4_Reg.wav');
            sounds{2} = audioread('sounds\interval 0\4.01_Reg.wav');
            sounds{3} = audioread('sounds\interval 0\4.02_Reg.wav');
            sounds{4} = audioread('sounds\interval 0\4.03_Reg.wav');
            sounds{5} = audioread('sounds\interval 0\4.06_Reg.wav');
            sounds{6} = audioread('sounds\interval 0\4_Irreg.wav');
            sounds{7} = audioread('sounds\interval 0\4.06_Irreg.wav');
            sounds{8} = audioread('sounds\interval 0\246_PT.wav');
            sounds = cellfun(@(x) x(1:min(fix(2 * fs), length(x))), sounds, 'UniformOutput', false);

        case 4 % active section 1 (one sound): code 121~130
            [sounds{1}, fs] = audioread('sounds\interval 0\4_Reg.wav');
            sounds{2} = audioread('sounds\interval 0\4.01_Reg.wav');
            sounds{3} = audioread('sounds\interval 0\4.02_Reg.wav');
            sounds{4} = audioread('sounds\interval 0\4.03_Reg.wav');
            sounds{5} = audioread('sounds\interval 0\4.06_Reg.wav');
            sounds{6} = audioread('sounds\interval 0\4_Irreg.wav');
            sounds{7} = audioread('sounds\interval 0\4.06_Irreg.wav');
            sounds{8} = audioread('sounds\interval 0\246_PT.wav');

            % control
            sounds{9} = audioread('sounds\interval 0\8_Irreg.wav');
            sounds{10} = audioread('sounds\interval 0\250_PT.wav');

            sounds = cellfun(@(x) x(1:min(fix(2 * fs), length(x))), sounds, 'UniformOutput', false);

        case 5 % active section 2 (two sounds): code 151~158
            [sounds{1}, fs] = audioread('sounds\interval 600\4_Reg.wav');
            sounds{2} = audioread('sounds\interval 600\4.01_Reg.wav');
            sounds{3} = audioread('sounds\interval 600\4.02_Reg.wav');
            sounds{4} = audioread('sounds\interval 600\4.03_Reg.wav');
            sounds{5} = audioread('sounds\interval 600\4.06_Reg.wav');
            sounds{6} = audioread('sounds\interval 600\4_Irreg.wav');
            sounds{7} = audioread('sounds\interval 600\4.06_Irreg.wav');

            % control
            sounds{8} = audioread('sounds\interval 600\8_Irreg.wav');

            sounds = cellfun(@(x) x(1:min(fix((2 + interval) * fs), length(x))), sounds, 'UniformOutput', false);

        case 6 % decoding: code 181~194
            [sounds{1}, fs] = audioread('sounds\decoding\2_Reg.wav');
            sounds{2} = audioread('sounds\decoding\3_Reg.wav');
            sounds{3} = audioread('sounds\decoding\4_Reg.wav');
            sounds{4} = audioread('sounds\decoding\5_Reg.wav');
            sounds{5} = audioread('sounds\decoding\6_Reg.wav');
            sounds{6} = audioread('sounds\decoding\7_Reg.wav');
            sounds{7} = audioread('sounds\decoding\8_Reg.wav');
            sounds{8} = audioread('sounds\decoding\2_Irreg.wav');
            sounds{9} = audioread('sounds\decoding\3_Irreg.wav');
            sounds{10} = audioread('sounds\decoding\4_Irreg.wav');
            sounds{11} = audioread('sounds\decoding\5_Irreg.wav');
            sounds{12} = audioread('sounds\decoding\6_Irreg.wav');
            sounds{13} = audioread('sounds\decoding\7_Irreg.wav');
            sounds{14} = audioread('sounds\decoding\8_Irreg.wav');
            sounds = cellfun(@(x) x(1:min(fix(fs), length(x))), sounds, 'UniformOutput', false);


         case 7 % TITS: code 211~212
            [sounds{1}, fs] = audioread('sounds\2022-11-10_TITS\interval 0\3s_24_26.4_RegStdDev.wav');
            sounds{2} = audioread('sounds\2022-11-10_TITS\interval 0\3s_24_60_RegDevStd.wav');
    end

    return;
end