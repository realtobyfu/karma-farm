import React, { useEffect, useState, useRef } from 'react';
import { StyleSheet, View, Dimensions } from 'react-native';
import MapView, { PROVIDER_GOOGLE, Region } from 'react-native-maps';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/native-stack';
import { YStack, Card, Button, XStack } from 'tamagui';
import { MapStackParamList } from '@lib/types';
import { usePostsStore } from '@store/posts';
import { DistanceSlider } from '@components/DistanceSlider';
import { MapMarker } from '@components/MapMarker';
import { colors } from '../../../tamagui.config';

type MapScreenNavigationProp = StackNavigationProp<MapStackParamList, 'MapScreen'>;

const { width, height } = Dimensions.get('window');
const ASPECT_RATIO = width / height;
const LATITUDE_DELTA = 0.0922;
const LONGITUDE_DELTA = LATITUDE_DELTA * ASPECT_RATIO;

export default function MapScreen() {
  const navigation = useNavigation<MapScreenNavigationProp>();
  const mapRef = useRef<MapView>(null);
  const [mapRegion, setMapRegion] = useState<Region | null>(null);
  
  const { 
    posts, 
    userLocation, 
    filters, 
    fetchPosts, 
    getUserLocation, 
    setFilters 
  } = usePostsStore();

  useEffect(() => {
    const initMap = async () => {
      // Get user location
      const location = await getUserLocation();
      
      if (location) {
        // Set initial map region to user location
        setMapRegion({
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          latitudeDelta: LATITUDE_DELTA,
          longitudeDelta: LONGITUDE_DELTA,
        });
      }

      // Fetch posts
      fetchPosts();
    };

    initMap();
  }, []);

  // Filter out posts without valid coordinates
  const postsWithCoordinates = posts.filter(post => 
    post.geom?.coordinates && 
    post.geom.coordinates.length === 2
  );

  // Navigate to post details
  const handlePostPress = (postId: string) => {
    navigation.navigate('PostDetails', { postId });
  };

  // Handle filter change
  const handleDistanceChange = (value: number) => {
    setFilters({ radius: value });
  };

  // Center map on user location
  const centerOnUser = () => {
    if (userLocation && mapRef.current) {
      mapRef.current.animateToRegion({
        latitude: userLocation.coords.latitude,
        longitude: userLocation.coords.longitude,
        latitudeDelta: LATITUDE_DELTA,
        longitudeDelta: LONGITUDE_DELTA,
      }, 1000);
    }
  };

  return (
    <View style={styles.container}>
      {mapRegion && (
        <MapView
          ref={mapRef}
          style={styles.map}
          provider={PROVIDER_GOOGLE}
          initialRegion={mapRegion}
          showsUserLocation
          showsMyLocationButton={false}
        >
          {postsWithCoordinates.map(post => (
            <MapMarker
              key={post.id}
              post={post}
              onPress={() => handlePostPress(post.id)}
            />
          ))}
        </MapView>
      )}
      
      {/* Floating filter card */}
      <YStack position="absolute" bottom={90} width="100%" alignItems="center">
        <Card 
          padding="$2" 
          marginHorizontal="$4" 
          backgroundColor={colors.background}
          borderRadius={16}
          elevate
          size="$4"
        >
          <DistanceSlider
            value={filters.radius || 10}
            onChange={handleDistanceChange}
            min={1}
            max={50}
          />
        </Card>
      </YStack>
      
      {/* Floating center button */}
      <XStack position="absolute" right={16} bottom={160}>
        <Button
          size="$3"
          circular
          backgroundColor={colors.background}
          onPress={centerOnUser}
          icon={<CenterIcon />}
        />
      </XStack>
    </View>
  );
}

// Simple center icon component
const CenterIcon = () => (
  <View style={{ width: 14, height: 14, borderRadius: 7, borderWidth: 2, borderColor: colors.primary }} />
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  map: {
    width: '100%',
    height: '100%',
  },
}); 