package net.morocoshi.common.loaders.fbx 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXPriority 
	{
		static private var n:int = 1;
		static private var data:Object = { };
		static private var FBXHeaderExtension:Object = { };
		static private var CreationTimeStamp:Object = { };
		
		public function FBXPriority() 
		{
		}
		
		static public function getPriority(parent:String, name:String):int
		{
			return (data[parent] && data[parent][name]) ? data[parent][name] : int.MAX_VALUE;
		}
		
		static public function init():void
		{
			var n:int = 1;
			data = { };
			
			data.Root = { };
			data.Root.FBXHeaderExtension = n++;
			data.Root.GlobalSettings = n++;
			data.Root.Documents = n++;
			data.Root.References = n++;
			data.Root.Definitions = n++;
			data.Root.Objects = n++;
			data.Root.Connections = n++;
			
			data.FBXHeaderExtension = { };
			data.FBXHeaderExtension.FBXHeaderVersion = n++;
			data.FBXHeaderExtension.FBXVersion = n++;
			data.FBXHeaderExtension.CreationTimeStamp = n++;
			data.FBXHeaderExtension.Creator = n++;
			data.FBXHeaderExtension.SceneInfo = n++;
			
			data.CreationTimeStamp = { };
			data.CreationTimeStamp.Version = n++;
			data.CreationTimeStamp.Year = n++;
			data.CreationTimeStamp.Month = n++;
			data.CreationTimeStamp.Day = n++;
			data.CreationTimeStamp.Hour = n++;
			data.CreationTimeStamp.Minute = n++;
			data.CreationTimeStamp.Second = n++;
			data.CreationTimeStamp.Millisecond = n++;
			
			data.SceneInfo = { };
			data.SceneInfo.Type = n++;
			data.SceneInfo.Version = n++;
			data.SceneInfo.MetaData = n++;
			data.SceneInfo.Properties70 = n++;
			
			data.MetaData = { };
			data.MetaData.Version = n++;
			data.MetaData.Title = n++;
			data.MetaData.Subject = n++;
			data.MetaData.Author = n++;
			data.MetaData.Keywords = n++;
			data.MetaData.Revision = n++;
			data.MetaData.Comment = n++;
			
			data.GlobalSettings = { };
			data.GlobalSettings.Version = n++;
			data.GlobalSettings.Properties70 = n++;
			
			data.Documents = { };
			data.Documents.Count = n++;
			data.Documents.Document = n++;
			
			data.Document = { };
			data.Document.Properties70 = n++;
			data.Document.RootNode = n++;
			
			data.Definitions = { };
			data.Definitions.Version = n++;
			data.Definitions.Count = n++;
			data.Definitions.ObjectType = n++;
			
			data.ObjectType = { };
			data.ObjectType.Count = n++;
			data.ObjectType.PropertyTemplate = n++;
			
			data.Objects = { };
			data.Objects.Geometry = n++;
			
			data.Geometry = { };
			data.Geometry.Properties70 = n++;
			data.Geometry.Vertices = n++;
			data.Geometry.PolygonVertexIndex = n++;
			data.Geometry.Edges = n++;
			data.Geometry.GeometryVersion = n++;
			data.Geometry.LayerElementNormal = n++;
			data.Geometry.LayerElementBinormal = n++;
			data.Geometry.LayerElementTangent = n++;
			data.Geometry.LayerElementColor = n++;
			data.Geometry.LayerElementUV = n++;
			data.Geometry.LayerElementVisibility = n++;
			data.Geometry.LayerElementMaterial = n++;
			data.Geometry.Layer = n++;
			
			data.LayerElementNormal = { };
			data.LayerElementNormal.Version = n++;
			data.LayerElementNormal.Name = n++;
			data.LayerElementNormal.MappingInformationType = n++;
			data.LayerElementNormal.ReferenceInformationType = n++;
			data.LayerElementNormal.Normals = n++;
			
			data.LayerElementBinormal = { };
			data.LayerElementBinormal.Version = n++;
			data.LayerElementBinormal.Name = n++;
			data.LayerElementBinormal.MappingInformationType = n++;
			data.LayerElementBinormal.ReferenceInformationType = n++;
			data.LayerElementBinormal.Binormals = n++;
			
			data.LayerElementTangent = { };
			data.LayerElementTangent.Version = n++;
			data.LayerElementTangent.Name = n++;
			data.LayerElementTangent.MappingInformationType = n++;
			data.LayerElementTangent.ReferenceInformationType = n++;
			data.LayerElementTangent.Tangents = n++;
			
			data.LayerElementUV = { };
			data.LayerElementUV.Version = n++;
			data.LayerElementUV.Name = n++;
			data.LayerElementUV.MappingInformationType = n++;
			data.LayerElementUV.ReferenceInformationType = n++;
			data.LayerElementUV.UV = n++;
			data.LayerElementUV.UVIndex = n++;
			
			data.LayerElementVisibility = { };
			data.LayerElementVisibility.Version = n++;
			data.LayerElementVisibility.Name = n++;
			data.LayerElementVisibility.MappingInformationType = n++;
			data.LayerElementVisibility.ReferenceInformationType = n++;
			data.LayerElementVisibility.Visibility = n++;
			
			data.LayerElementMaterial = { };
			data.LayerElementMaterial.Version = n++;
			data.LayerElementMaterial.Name = n++;
			data.LayerElementMaterial.MappingInformationType = n++;
			data.LayerElementMaterial.ReferenceInformationType = n++;
			data.LayerElementMaterial.Materials = n++;
			
			data.Layer = { };
			data.Layer.Version = n++;
			data.Layer.LayerElement = n++;
			
			data.LayerElement = { };
			data.LayerElement.Type = n++;
			data.LayerElement.TypedIndex = n++;
			
			data.Model = { };
			data.Model.Version = n++;
			data.Model.Properties70 = n++;
			data.Model.MultiLayer = n++;
			data.Model.MultiTake = n++;
			data.Model.Shading = n++;
			data.Model.Culling = n++;
			
			data.Material = { };
			data.Material.Version = n++;
			data.Material.ShadingModel = n++;
			data.Material.MultiLayer = n++;
			data.Material.Properties70 = n++;
			
			data.Video = { };
			data.Video.Type = n++;
			data.Video.Properties70 = n++;
			data.Video.UseMipMap = n++;
			data.Video.Filename = n++;
			data.Video.RelativeFilename = n++;
			
			data.Texture = { };
			data.Texture.Type = n++;
			data.Texture.Version = n++;
			data.Texture.TextureName = n++;
			data.Texture.Properties70 = n++;
			data.Texture.Media = n++;
			data.Texture.FileName = n++;
			data.Texture.RelativeFilename = n++;
			data.Texture.ModelUVTranslation = n++;
			data.Texture.ModelUVScaling = n++;
			data.Texture.Texture_Alpha_Source = n++;
			data.Texture.Cropping = n++;
			
		}
		
	}

}