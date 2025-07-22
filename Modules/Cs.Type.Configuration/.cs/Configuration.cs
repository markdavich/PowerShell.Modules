using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

namespace Cs.Type;

public class Configuration<TConfig>(string path)
{
    public TConfig Load()
    {
        if (!File.Exists(path))
        {
            return CreateDefault();
        }

        using FileStream stream = File.OpenRead(path);
        TConfig config = JsonSerializer.Deserialize<TConfig>(stream)
                           ?? throw new InvalidDataException("Failed to deserialize config.");
        return config;
    }

    public void Save(TConfig config)
    {
        var options = new JsonSerializerOptions
        {
            WriteIndented = true
        };

        string json = JsonSerializer.Serialize(config, options);
        File.WriteAllText(path, json);
    }

    private TConfig CreateDefault()
    {
        // Create an empty config with default values
        TConfig config = Activator.CreateInstance<TConfig>()
                         ?? throw new InvalidOperationException($"Could not create instance of {typeof(TConfig).Name}");

        Save(config); // Save it immediately so the user can edit it
        return config;
    }
}
